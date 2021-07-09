-- 新規タイムラインを設定する
insert into d_timeline(timeline_name) values('インストール後動作確認用');

-- timeline_idを確認し、以下のクエリに設定する
select * from d_timeline;

insert into d_stage_history(timeline_id, stage_name, stage_detail, stage_target, detail)
select
  1 as timeline_id,
  stage_name as stage_name,
  detail as stage_detail,
  target as stage_target,
  '' as detail
from m_stage
where stage_id = 1
;

insert into d_task_status(
  timeline_id,
  task_id,
  group_name,
  group_short_name,
  group_name_eng,
  role_name,
  organization_name,
  organization_sub_name,
  stage_name,
  stage_detail,
  task_detail,
  task_status,
  phase_id
)
select
  1 as timeline_id,
  t.task_id,
  g.group_name,
  g.group_short_name,
  g.group_name_eng,
  r.role_name,
  o.organization_name,
  o.organization_sub_name,
  s.stage_name,
  s.detail as stage_detail,
  t.task_detail,
  0 as task_status,
  t.phase_id
from m_task t 
left join m_organization o
  on t.organization_id = o.organization_id
left join m_role r
  on t.role_id = r.role_id
left join m_group g
  on r.group_id = g.group_id
left join m_stage s
  on t.stage_id = s.stage_id
;
