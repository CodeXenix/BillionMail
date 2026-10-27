#!/bin/bash
# Seed demo data into a running Xenix Mail stack: a sending domain with mailboxes,
# contact groups/tags, templates and completed campaigns with delivery/open/click stats.
# Re-running replaces the previous demo data. Only reserved example.* domains are used,
# and campaigns are inserted as already completed, so nothing is ever sent.
#
# Usage: bash seed-demo.sh
#        DOCKER=docker.exe bash seed-demo.sh   # WSL without Docker Desktop integration
set -eu
cd "$(dirname "$0")"

DOCKER=${DOCKER:-docker}
PGSQL_CONTAINER_NAME=billionmail-pgsql-billionmail-1
DOVECOT_CONTAINER_NAME=billionmail-dovecot-billionmail-1
DBUSER=$(grep '^DBUSER=' .env | cut -d= -f2)
DBNAME=$(grep '^DBNAME=' .env | cut -d= -f2)

# Mailbox password, hashed the same way install.sh does
MAILBOX_PASSWORD=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2>/dev/null | head -c 12)
PW_HASH=$($DOCKER exec -i "$DOVECOT_CONTAINER_NAME" doveadm pw -s MD5-CRYPT -p "$MAILBOX_PASSWORD" | sed 's/{MD5-CRYPT}//' | tr -d '\r')
PW_ENC=$(printf %s "$MAILBOX_PASSWORD" | base64 | tr -d '\n' | od -A n -t x1 | tr -d ' \n')
[ -n "$PW_HASH" ] || { echo "Failed to hash the mailbox password; is $DOVECOT_CONTAINER_NAME running?" >&2; exit 1; }

$DOCKER exec -i "$PGSQL_CONTAINER_NAME" psql -q -1 -v ON_ERROR_STOP=1 -U "$DBUSER" -d "$DBNAME" \
	-v pw_hash="$PW_HASH" -v pw_enc="$PW_ENC" <<'SQL'
SELECT setseed(0.42), extract(epoch FROM now())::int AS now, extract(epoch FROM date_trunc('day', now()))::int AS today \gset

CREATE TEMP TABLE demo_group (name text, description text, size int, age_days int) ON COMMIT DROP;
INSERT INTO demo_group VALUES
	('Newsletter Subscribers', 'Signed up through the website newsletter form', 1200, 95),
	('Customers', 'Paying customers synced from billing', 400, 90),
	('Webinar Leads', 'Registered for the "Email at Scale" webinar', 250, 60);

CREATE TEMP TABLE demo_template (name text, accent text, heading text, body text, cta_url text, cta_text text) ON COMMIT DROP;
INSERT INTO demo_template VALUES
	('Welcome Email', '#2563eb', 'Welcome aboard!', 'Thanks for joining Acme. Over the next few weeks we will share tips to help you get the most out of your account.', 'https://example.com/get-started', 'Get started'),
	('Monthly Newsletter', '#0f766e', 'What''s new this month', 'Product updates, customer stories and the best reads from our blog, all in one place.', 'https://example.com/blog', 'Read the highlights'),
	('Product Launch', '#7c3aed', 'Introducing Smart Reports', 'See opens, clicks and revenue for every campaign in one dashboard. Available today on all plans.', 'https://example.com/features/reports', 'See what''s new'),
	('Webinar Invitation', '#ea580c', 'Email at Scale: live webinar', 'Join our deliverability team for 45 minutes on IP warmup, list hygiene and inbox placement.', 'https://example.com/webinar', 'Save my seat');

-- days_ago = 0 means "earlier today", so the overview's default Today view has data
CREATE TEMP TABLE demo_campaign (task_name text, subject text, template text, grp text, sender text, days_ago int, open_rate numeric, click_rate numeric, link text, start_time int) ON COMMIT DROP;
INSERT INTO demo_campaign (task_name, subject, template, grp, sender, days_ago, open_rate, click_rate, link) VALUES
	('Welcome Series', 'Welcome to Acme: here''s how to get started', 'Welcome Email', 'Newsletter Subscribers', 'news', 84, .55, .21, 'https://example.com/get-started'),
	('Newsletter - Issue 1', 'What''s new at Acme this month', 'Monthly Newsletter', 'Newsletter Subscribers', 'news', 63, .37, .08, 'https://example.com/blog'),
	('Smart Reports Launch', 'Introducing Smart Reports', 'Product Launch', 'Customers', 'sales', 49, .48, .16, 'https://example.com/features/reports'),
	('Webinar Invitation', 'You''re invited: Email at Scale (live)', 'Webinar Invitation', 'Webinar Leads', 'news', 35, .44, .19, 'https://example.com/webinar'),
	('Newsletter - Issue 2', 'Customer stories, new integrations and more', 'Monthly Newsletter', 'Newsletter Subscribers', 'news', 28, .35, .07, 'https://example.com/blog'),
	('Webinar Recording', 'The "Email at Scale" recording is ready', 'Webinar Invitation', 'Webinar Leads', 'news', 20, .41, .24, 'https://example.com/webinar/recording'),
	('Renewal Offer', 'A thank-you: 20% off your next renewal', 'Product Launch', 'Customers', 'sales', 9, .51, .17, 'https://example.com/account/renew'),
	('Newsletter - Issue 3', 'Your monthly Acme roundup', 'Monthly Newsletter', 'Newsletter Subscribers', 'news', 2, .33, .08, 'https://example.com/blog'),
	('Automation Tips', '3 automations that save you hours every week', 'Monthly Newsletter', 'Customers', 'sales', 0, .27, .06, 'https://example.com/blog/automation-tips');
UPDATE demo_campaign SET start_time = CASE WHEN days_ago = 0 THEN :today + (:now - :today) / 4 ELSE :now - days_ago * 86400 END;

-- 1. Remove the previous demo run
DELETE FROM mailstat_opened WHERE postfix_message_id LIKE 'DEMO%';
DELETE FROM mailstat_clicked WHERE postfix_message_id LIKE 'DEMO%';
DELETE FROM mailstat_deferred_mails WHERE postfix_message_id LIKE 'DEMO%';
DELETE FROM mailstat_send_mails WHERE postfix_message_id LIKE 'DEMO%';
DELETE FROM mailstat_senders WHERE postfix_message_id LIKE 'DEMO%';
DELETE FROM mailstat_message_ids WHERE postfix_message_id LIKE 'DEMO%';
DELETE FROM recipient_info WHERE task_id IN (SELECT id FROM email_tasks WHERE addresser LIKE '%@example.com');
DELETE FROM email_tasks WHERE addresser LIKE '%@example.com';
DELETE FROM unsubscribe_records WHERE email LIKE '%@example.net' OR email LIKE '%@example.org';
DELETE FROM abnormal_recipient WHERE recipient LIKE '%@example.net' OR recipient LIKE '%@example.org';
DELETE FROM bm_contact_tags WHERE tag_id IN (SELECT t.id FROM bm_tags t JOIN bm_contact_groups g ON g.id = t.group_id JOIN demo_group d ON d.name = g.name);
DELETE FROM bm_tags WHERE group_id IN (SELECT g.id FROM bm_contact_groups g JOIN demo_group USING (name));
DELETE FROM bm_contacts WHERE group_id IN (SELECT g.id FROM bm_contact_groups g JOIN demo_group USING (name));
DELETE FROM bm_contact_groups WHERE name IN (SELECT name FROM demo_group);
DELETE FROM email_templates WHERE temp_name IN (SELECT name FROM demo_template);
DELETE FROM mailbox WHERE domain = 'example.com';
DELETE FROM domain WHERE domain = 'example.com';

-- 2. Sending domain and mailboxes
INSERT INTO domain (domain, a_record, mailboxes, mailbox_quota, quota, rate_limit, create_time, active)
VALUES ('example.com', 'mail.example.com', 50, 5368709120, 10737418240, 12, :now - 100 * 86400, 1);

INSERT INTO mailbox (username, password, password_encode, full_name, is_admin, maildir, quota, local_part, domain, create_time, update_time, active)
SELECT lp || '@example.com', :'pw_hash', :'pw_enc', full_name, 0, lp || '@example.com/', 5368709120, lp, 'example.com', :now - 100 * 86400, :now - 100 * 86400, 1
FROM (VALUES ('news', 'Acme Newsletter'), ('sales', 'Acme Sales'), ('support', 'Acme Support')) v(lp, full_name);

-- 3. Contact groups, contacts (sqrt skews signups older, so lists grow over time) and tags
INSERT INTO bm_contact_groups (name, description, create_time, update_time)
SELECT name, description, :now - age_days * 86400, :now - age_days * 86400 FROM demo_group;

WITH person AS MATERIALIZED (
	SELECT g.id AS group_id, i,
		(ARRAY['Emma','Liam','Olivia','Noah','Ava','Elijah','Sophia','James','Isabella','Lucas','Mia','Mason','Amelia','Ethan','Harper','Logan','Evelyn','Aiden','Abigail','Jackson','Emily','Sebastian','Ella','Mateo','Chloe','Henry','Aria','Leo','Zoe','Daniel','Nora','Owen','Lily','Samuel','Hannah','Ryan','Layla','Nathan','Grace','Omar'])[1 + floor(random() * 40)::int] AS first_name,
		(ARRAY['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez','Hernandez','Lopez','Wilson','Anderson','Thomas','Taylor','Moore','Jackson','Martin','Lee','Thompson','White','Harris','Clark','Lewis','Robinson','Walker','Young','Allen','King','Wright','Scott','Hill','Green','Adams','Baker','Nelson','Carter','Khan','Patel'])[1 + floor(random() * 40)::int] AS last_name,
		(ARRAY['Northwind','Globex','Initech','Umbrella Labs','Stark Retail','Wayne Logistics','Hooli','Vandelay Imports','Soylent Foods','Cyberdyne','Pied Piper','Wonka Sweets','Tyrell Media','Oscorp','Massive Dynamic'])[1 + floor(random() * 15)::int] AS company,
		(ARRAY['New York','London','Toronto','Berlin','Sydney','Austin','Dubai','Singapore','Paris','Karachi','Chicago','Amsterdam'])[1 + floor(random() * 12)::int] AS city,
		:now - floor(sqrt(random()) * d.age_days * 86400)::int AS created,
		random() AS r_active
	FROM demo_group d
	JOIN bm_contact_groups g USING (name)
	CROSS JOIN generate_series(1, d.size) i
)
INSERT INTO bm_contacts (email, group_id, active, create_time, status, attribs, last_active_at)
SELECT lower(first_name || '.' || last_name || i) || CASE WHEN i % 3 = 0 THEN '@example.org' ELSE '@example.net' END,
	group_id, CASE WHEN r_active < .03 THEN 0 ELSE 1 END, created, 1,
	jsonb_build_object('first_name', first_name, 'last_name', last_name, 'company', company, 'city', city), created
FROM person;

INSERT INTO bm_tags (group_id, name, create_time)
SELECT g.id, t.name, g.create_time + 86400
FROM bm_contact_groups g
JOIN (VALUES ('Newsletter Subscribers', 'Engaged'), ('Newsletter Subscribers', 'Inactive'), ('Newsletter Subscribers', 'Product updates'),
	('Customers', 'VIP'), ('Customers', 'Enterprise'), ('Customers', 'Churn risk'),
	('Webinar Leads', 'Attended'), ('Webinar Leads', 'No-show')) t(grp, name) ON g.name = t.grp
ORDER BY g.id;

-- tag ids within a group are consecutive, so (contact + tag) % 4 gives each contact at most one tag
INSERT INTO bm_contact_tags (contact_id, tag_id, create_time)
SELECT c.id, t.id, c.create_time
FROM bm_contacts c
JOIN bm_tags t ON t.group_id = c.group_id
WHERE c.group_id IN (SELECT g.id FROM bm_contact_groups g JOIN demo_group USING (name)) AND (c.id + t.id) % 4 = 0;

-- 4. Templates (add_type 0 = HTML)
INSERT INTO email_templates (temp_name, add_type, content, render, create_time, update_time)
SELECT name, 0, format($html$<!DOCTYPE html>
<html><body style="margin:0;background:#f4f5f7;font-family:Arial,Helvetica,sans-serif;color:#1f2937">
<table role="presentation" width="100%%" cellpadding="0" cellspacing="0"><tr><td align="center" style="padding:32px 16px">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width:600px;background:#ffffff;border-radius:8px">
<tr><td style="background:%1$s;padding:24px 32px;color:#ffffff;font-size:20px;font-weight:bold;border-radius:8px 8px 0 0">Acme</td></tr>
<tr><td style="padding:32px">
<h1 style="margin:0 0 16px;font-size:24px">%2$s</h1>
<p style="margin:0 0 24px;line-height:1.6">Hi there,<br><br>%3$s</p>
<a href="%4$s" style="display:inline-block;background:%1$s;color:#ffffff;padding:12px 24px;border-radius:6px;text-decoration:none;font-weight:bold">%5$s</a>
</td></tr>
<tr><td style="padding:16px 32px;background:#f9fafb;font-size:12px;color:#6b7280;border-radius:0 0 8px 8px">Sent to {{.Subscriber.Email}} by Acme Inc., 123 Demo Street, Springfield. <a href="__UNSUBSCRIBE_URL__" style="color:#6b7280">Unsubscribe</a></td></tr>
</table></td></tr></table></body></html>$html$, accent, heading, body, cta_url, cta_text), '', :now - 100 * 86400, :now - 100 * 86400
FROM demo_template;

-- 5. Completed campaigns (task_process 2) so the task executor never picks them up
INSERT INTO email_tasks (task_name, addresser, subject, full_name, recipient_count, task_process, pause, template_id, is_record, unsubscribe, threads, track_open, track_click, start_time, create_time, update_time, active, add_type, group_id, remark)
SELECT dc.task_name, m.username, dc.subject, m.full_name, 0, 2, 0, t.id, 1, 1, 0, 1, 1, dc.start_time, dc.start_time - 86400, dc.start_time + 7200, 1, 0, g.id, ''
FROM demo_campaign dc
JOIN mailbox m ON m.username = dc.sender || '@example.com'
JOIN email_templates t ON t.temp_name = dc.template
JOIN bm_contact_groups g ON g.name = dc.grp;

-- One row per delivery attempt: contacts that existed when the campaign went out
CREATE TEMP TABLE demo_send ON COMMIT DROP AS
WITH s AS MATERIALIZED (
	SELECT t.id AS task_id, t.addresser, c.id AS contact_id, c.email, dc.open_rate, dc.click_rate, dc.link,
		'DEMO' || t.id || 'X' || c.id AS pmid,
		md5(t.id || '-' || c.id) || '@example.com' AS msgid,
		t.start_time + floor(random() * least(7200, (:now - t.start_time) / 2))::int AS sent_at,
		random() AS r_status, random() AS r_open, random() AS r_click, random() AS r_provider
	FROM demo_campaign dc
	JOIN email_tasks t ON t.task_name = dc.task_name AND t.addresser = dc.sender || '@example.com'
	JOIN bm_contacts c ON c.group_id = t.group_id AND c.create_time < t.start_time
)
SELECT s.*,
	CASE WHEN r_status < .035 THEN 'bounced' WHEN r_status < .055 THEN 'deferred' ELSE 'sent' END AS status,
	CASE WHEN r_provider < .44 THEN 'google' WHEN r_provider < .66 THEN 'outlook' WHEN r_provider < .79 THEN 'yahoo'
		WHEN r_provider < .89 THEN 'apple' WHEN r_provider < .93 THEN 'proton' WHEN r_provider < .95 THEN 'zoho' ELSE 'other' END AS provider
FROM s;

-- opens skew early (random^3) and never land in the future; clicks follow opens
ALTER TABLE demo_send ADD COLUMN open_at int, ADD COLUMN click_at int;
UPDATE demo_send SET open_at = sent_at + floor(power(random(), 3) * greatest(0, least(3 * 86400, :now - 120 - sent_at)))::int
WHERE status = 'sent' AND r_open < open_rate;
UPDATE demo_send SET click_at = least(open_at + floor(random() * 900)::int, :now - 60)
WHERE open_at IS NOT NULL AND r_click < click_rate / open_rate;

INSERT INTO recipient_info (task_id, recipient, is_sent, sent_time, message_id, create_time)
SELECT task_id, email, 1, sent_at, msgid, sent_at FROM demo_send;

INSERT INTO mailstat_message_ids (postfix_message_id, log_time_millis, message_id)
SELECT pmid, sent_at * 1000::bigint, msgid FROM demo_send;

INSERT INTO mailstat_senders (postfix_message_id, log_time_millis, size, sender)
SELECT pmid, sent_at * 1000::bigint, 18000 + floor(random() * 30000)::int, addresser FROM demo_send;

INSERT INTO mailstat_send_mails (postfix_message_id, log_time_millis, status, recipient, mail_provider, delay, delays, dsn, relay, description)
SELECT pmid, sent_at * 1000::bigint + 800, status, email, provider, round((0.3 + random() * 2)::numeric, 2), '0.02/0.01/0.15/0.4',
	CASE status WHEN 'sent' THEN '2.0.0' WHEN 'bounced' THEN '5.1.1' ELSE '4.7.0' END,
	'mx.' || split_part(email, '@', 2) || '[203.0.113.' || (contact_id % 250 + 1) || ']:25',
	CASE status WHEN 'sent' THEN '250 2.0.0 OK: queued'
		WHEN 'bounced' THEN 'host mx.' || split_part(email, '@', 2) || ' said: 550 5.1.1 <' || email || '>: Recipient address rejected: User unknown'
		ELSE 'host mx.' || split_part(email, '@', 2) || ' said: 421 4.7.0 Try again later, closing connection' END
FROM demo_send;

INSERT INTO mailstat_deferred_mails (postfix_message_id, log_time_millis, delay, delays, dsn, relay, description)
SELECT pmid, sent_at * 1000::bigint + 800, 1.2, '0.02/0.01/0.6/0.6', '4.7.0',
	'mx.' || split_part(email, '@', 2) || '[203.0.113.' || (contact_id % 250 + 1) || ']:25',
	'host mx.' || split_part(email, '@', 2) || ' said: 421 4.7.0 Try again later, closing connection'
FROM demo_send WHERE status = 'deferred';

INSERT INTO mailstat_opened (campaign_id, log_time_millis, recipient, postfix_message_id, message_id)
SELECT task_id, open_at * 1000::bigint, email, pmid, msgid FROM demo_send WHERE open_at IS NOT NULL;

INSERT INTO mailstat_clicked (campaign_id, log_time_millis, recipient, url, postfix_message_id, message_id)
SELECT task_id, click_at * 1000::bigint, email, CASE WHEN random() < .75 THEN link ELSE 'https://example.com/pricing' END, pmid, msgid
FROM demo_send WHERE click_at IS NOT NULL;

-- 6. Campaign counters (the stats timer recomputes these the same way), engagement, unsubscribes, bounces
UPDATE email_tasks t SET recipient_count = s.sends, sends_count = s.sends, delivered_count = s.delivered,
	bounced_count = s.bounced, deferred_count = s.deferred, stats_update_time = :now
FROM (SELECT task_id, count(*) AS sends, count(*) FILTER (WHERE status = 'sent') AS delivered,
	count(*) FILTER (WHERE status = 'bounced') AS bounced, count(*) FILTER (WHERE status = 'deferred') AS deferred
	FROM demo_send GROUP BY task_id) s
WHERE t.id = s.task_id;

UPDATE bm_contacts c SET last_active_at = s.t
FROM (SELECT contact_id, greatest(max(open_at), max(click_at)) AS t FROM demo_send WHERE open_at IS NOT NULL GROUP BY contact_id) s
WHERE c.id = s.contact_id;

-- unsubscribed contacts opted out a few hours after the last campaign they received
INSERT INTO unsubscribe_records (email, group_id, template_id, task_id, unsubscribe_time)
SELECT c.email, c.group_id, coalesce(t.template_id, 0), coalesce(t.id, 0),
	least(coalesce(ls.sent_at + 3600 + floor(random() * 86400)::int, c.create_time + 86400), :now - 60)
FROM bm_contacts c
LEFT JOIN LATERAL (SELECT task_id, sent_at FROM demo_send d WHERE d.contact_id = c.id ORDER BY sent_at DESC LIMIT 1) ls ON true
LEFT JOIN email_tasks t ON t.id = ls.task_id
WHERE c.active = 0 AND c.group_id IN (SELECT g.id FROM bm_contact_groups g JOIN demo_group USING (name));

INSERT INTO abnormal_recipient (recipient, count, description, add_type, create_time)
SELECT email, count(*), '550 5.1.1 User unknown', 0, max(sent_at) FROM demo_send WHERE status = 'bounced' GROUP BY email
ON CONFLICT (recipient) DO NOTHING;

\echo
SELECT (SELECT count(*) FROM bm_contacts WHERE email LIKE '%@example.net' OR email LIKE '%@example.org') AS contacts,
	(SELECT count(*) FROM email_tasks WHERE addresser LIKE '%@example.com') AS campaigns,
	count(*) AS sends,
	count(*) FILTER (WHERE status = 'sent') AS delivered,
	count(open_at) AS opened,
	count(click_at) AS clicked,
	count(*) FILTER (WHERE status = 'bounced') AS bounced
FROM demo_send;
SQL

echo "Demo mailboxes (webmail at /roundcube/): news@example.com, sales@example.com, support@example.com"
echo "Mailbox password: $MAILBOX_PASSWORD"
