"""E2E: Campaign edit — which campaigns POST /api/batch_mail/task/update may change, and how."""

import time

import pytest

from helpers import api


async def _find(bm_api, task_id):
    resp = await api.get(bm_api, "/api/batch_mail/task/find", params={"id": task_id})
    return resp.json()["data"]


async def _update(bm_api, **fields):
    resp = await api.post(bm_api, "/api/batch_mail/task/update", json=fields)
    return resp.json()


@pytest.mark.asyncio
async def test_edit_campaign(bm_api, db, seed_data):
    # Scheduled a month out so the campaign never sends during the test
    future = int(time.time()) + 30 * 86400
    resp = await api.post(
        bm_api,
        "/api/batch_mail/task/create",
        json={
            "addresser": seed_data["sender_email"],
            "full_name": "E2E",
            "subject": "e2e edit original",
            "group_id": seed_data["group_id"],
            "template_id": seed_data["template_id"],
            "is_record": 0,
            "unsubscribe": 1,
            "warmup": 0,
            "threads": 0,
            "start_time": future,
            "remark": "note",
            "tag_ids": [],
            "tag_logic": "OR",
            "track_open": 1,
            "track_click": 1,
        },
    )
    task_id = resp.json()["data"]["id"]
    try:
        # Not started: everything can change, the send time included
        res = await _update(
            bm_api, task_id=task_id, subject="e2e edit changed", track_open=0, threads=5, remark="", start_time=future + 60
        )
        assert res["success"], res
        task = await _find(bm_api, task_id)
        assert (task["subject"], task["track_open"], task["threads"], task["remark"], task["start_time"]) == (
            "e2e edit changed", 0, 5, "", future + 60,
        )

        # Fields left out keep their value
        assert (await _update(bm_api, task_id=task_id, full_name="Partial"))["success"]
        task = await _find(bm_api, task_id)
        assert (task["full_name"], task["track_open"], task["threads"], task["unsubscribe"]) == ("Partial", 0, 5, 1)

        assert not (await _update(bm_api, task_id=task_id))["success"]
        assert not (await _update(bm_api, task_id=task_id, template_id=99999999))["success"]

        # Paused: content can change, the send time no longer applies
        await db.execute("UPDATE email_tasks SET task_process = 3, pause = 1 WHERE id = $1", task_id)
        assert (await _update(bm_api, task_id=task_id, subject="paused edit", start_time=future + 120))["success"]
        assert (await _find(bm_api, task_id))["start_time"] == future + 60

        # Sending must be paused first; completed cannot change
        await db.execute("UPDATE email_tasks SET task_process = 1, pause = 0 WHERE id = $1", task_id)
        assert not (await _update(bm_api, task_id=task_id, subject="x"))["success"]
        await db.execute("UPDATE email_tasks SET task_process = 2 WHERE id = $1", task_id)
        assert not (await _update(bm_api, task_id=task_id, subject="x"))["success"]
        assert (await _find(bm_api, task_id))["subject"] == "paused edit"
    finally:
        await db.execute("UPDATE email_tasks SET task_process = 2, pause = 1 WHERE id = $1", task_id)
        await api.post(bm_api, "/api/batch_mail/task/delete", json={"id": task_id})
