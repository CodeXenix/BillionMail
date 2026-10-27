package batch_mail

import (
	"context"
	"time"
	"xenixmail-core/internal/consts"
	"xenixmail-core/internal/service/batch_mail"
	"xenixmail-core/internal/service/email_template"
	"xenixmail-core/internal/service/public"

	"github.com/gogf/gf/v2/errors/gerror"
	"github.com/gogf/gf/v2/frame/g"

	"xenixmail-core/api/batch_mail/v1"
)

func (c *ControllerV1) UpdateTaskInfo(ctx context.Context, req *v1.UpdateTaskInfoReq) (res *v1.UpdateTaskInfoRes, err error) {

	res = &v1.UpdateTaskInfoRes{}

	var task struct {
		Id          int    `json:"id"`
		TaskProcess int    `json:"task_process"`
		Pause       int    `json:"pause"`
		Subject     string `json:"subject"`
	}

	err = g.DB().Model("email_tasks").
		Fields("id, task_process, pause, subject").
		Where("id", req.TaskId).
		Scan(&task)

	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Query task failed: {}", err.Error())))
		return nil, err
	}

	if task.Id == 0 {
		res.SetError(gerror.New(public.LangCtx(ctx, "The task does not exist.")))
		return
	}

	// task_process: 0 not started, 1 sending, 2 completed, 3 paused
	if task.TaskProcess == 2 {
		res.SetError(gerror.New(public.LangCtx(ctx, "A completed task cannot be edited.")))
		return
	}
	if task.TaskProcess == 1 && task.Pause == 0 {
		res.SetError(gerror.New(public.LangCtx(ctx, "The task is currently running. Please pause the task first.")))
		return
	}

	updateData := g.Map{}

	if req.Addresser != "" {
		updateData["addresser"] = req.Addresser
	}
	if req.Subject != "" {
		updateData["subject"] = req.Subject
	}
	if req.FullName != "" {
		updateData["full_name"] = req.FullName
	}
	if req.Remark != nil {
		updateData["remark"] = *req.Remark
	}
	if req.TemplateId > 0 {
		template, e := email_template.GetTemplate(ctx, req.TemplateId)
		if e != nil || template == nil {
			res.SetError(gerror.New(public.LangCtx(ctx, "Template not found")))
			return
		}
		updateData["template_id"] = req.TemplateId
	}
	if req.Unsubscribe != nil {
		updateData["unsubscribe"] = *req.Unsubscribe
	}
	if req.TrackOpen != nil {
		updateData["track_open"] = *req.TrackOpen
	}
	if req.TrackClick != nil {
		updateData["track_click"] = *req.TrackClick
	}
	if req.Threads != nil {
		updateData["threads"] = *req.Threads
	}
	// A paused task continues when it is resumed, so the send time only matters before sending starts
	if req.StartTime > 0 && task.TaskProcess == 0 {
		updateData["start_time"] = req.StartTime
	}

	if len(updateData) == 0 && req.Warmup == nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "No valid update fields")))
		return
	}

	updateData["update_time"] = time.Now().Unix()

	_, err = g.DB().Model("email_tasks").
		Where("id", req.TaskId).
		Data(updateData).
		Update()

	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to update task information : {}", err.Error())))
		return nil, err
	}

	// ponytail: a paused task whose executor is still in memory keeps its old warmup pacing until core restarts
	if req.Warmup != nil {
		if err = batch_mail.SetTaskWarmup(ctx, req.TaskId, *req.Warmup == 1); err != nil {
			res.SetError(gerror.New(public.LangCtx(ctx, "Failed to update task information : {}", err.Error())))
			return nil, err
		}
	}

	subject := task.Subject
	if req.Subject != "" {
		subject = req.Subject
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Task,
		Log:  "Update Task Info :" + subject + " successfully",
		Data: updateData,
	})

	res.SetSuccess(public.LangCtx(ctx, "Task update successful"))
	return
}
