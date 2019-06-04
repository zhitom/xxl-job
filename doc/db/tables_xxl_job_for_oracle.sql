--CREATE database xxl-job default character set utf8 collate utf8_general_ci;
--use xxl-job;

--------------------------------------------------------
--modify:
--xxl_job_user username -> wusername
--xxl_job_group_id order -> worder
--xxl_job_logglue -> trigger
---------------------------------------------------------
--xxl_job_info
---------------------------------------------------------
DROP SEQUENCE xxl_job_info_id;
CREATE SEQUENCE xxl_job_info_id START WITH 100;
SELECT xxl_job_info_id.NEXTVAL FROM DUAL;
drop table xxl_job_info;
CREATE TABLE xxl_job_info (
  id number(11) NOT NULL ,
  job_group number(11) NOT NULL ,
  job_cron varchar2(128) NOT NULL,
  job_desc varchar2(255) NOT NULL,
  add_time date DEFAULT NULL,
  update_time date DEFAULT NULL,
  author varchar2(64) DEFAULT NULL ,
  alarm_email varchar2(255) DEFAULT NULL ,
  executor_route_strategy varchar2(50) DEFAULT NULL ,
  executor_handler varchar2(255) DEFAULT NULL ,
  executor_param varchar2(512) DEFAULT NULL ,
  executor_block_strategy varchar2(50) DEFAULT NULL ,
  executor_timeout number(11) DEFAULT '0' ,
  executor_fail_retry_count number(11) DEFAULT '0' ,
  glue_type varchar2(50) NOT NULL ,
  glue_source clob ,
  glue_remark varchar2(128) DEFAULT NULL ,
  glue_updatetime date DEFAULT NULL ,
  child_jobid varchar2(255) DEFAULT NULL ,
  trigger_status number(4) DEFAULT '0' ,
  trigger_last_time number(13) DEFAULT '0',
  trigger_next_time number(13) DEFAULT '0' 
)tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 80K
    minextents 1
    maxextents unlimited
  );
comment on column xxl_job_info.job_group is '执行器主键ID';
comment on column xxl_job_info.job_cron is '任务执行CRON';
comment on column xxl_job_info.author is '作者';
comment on column xxl_job_info.alarm_email is '报警邮件';
comment on column xxl_job_info.executor_route_strategy is '执行器路由策略';
comment on column xxl_job_info.executor_handler is '执行器任务handler';
comment on column xxl_job_info.executor_param is '执行器任务参数';
comment on column xxl_job_info.executor_block_strategy is '阻塞处理策略';
comment on column xxl_job_info.executor_timeout is '任务执行超时时间，单位秒';
comment on column xxl_job_info.executor_fail_retry_count is '失败重试次数';
comment on column xxl_job_info.glue_type is 'GLUE类型';
comment on column xxl_job_info.glue_source is 'GLUE源代码';
comment on column xxl_job_info.glue_remark is 'GLUE备注';
comment on column xxl_job_info.glue_updatetime is 'GLUE更新时间';
comment on column xxl_job_info.child_jobid is '子任务ID，多个逗号分隔';
comment on column xxl_job_info.trigger_status is '调度状态：0-停止，1-运行';
comment on column xxl_job_info.trigger_last_time is '上次调度时间';
comment on column xxl_job_info.trigger_next_time is '下次调度时间';
alter table xxl_job_info
  add constraint PK_xxl_job_info primary key (ID)
  using index
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
---------------------------------------------------------
--xxl_job_log
---------------------------------------------------------
DROP SEQUENCE xxl_job_log_id;
CREATE SEQUENCE xxl_job_log_id START WITH 100;
SELECT xxl_job_log_id.NEXTVAL FROM DUAL;
drop table xxl_job_log;
CREATE TABLE xxl_job_log (
  id number(11) NOT NULL,
  job_group number(11) NOT NULL ,
  job_id number(11) NOT NULL ,
  executor_address varchar2(255) DEFAULT NULL ,
  executor_handler varchar2(255) DEFAULT NULL ,
  executor_param varchar2(512) DEFAULT NULL ,
  executor_sharding_param varchar2(20) DEFAULT NULL ,
  executor_fail_retry_count number(11) DEFAULT '0' ,
  trigger_time date  DEFAULT NULL ,
  trigger_code number(11) NOT NULL ,
  trigger_msg clob ,
  handle_time date DEFAULT NULL ,
  handle_code number(11) NOT NULL ,
  handle_msg clob ,
  alarm_status number(4) DEFAULT '0' 
)tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 80K
    minextents 1
    maxextents unlimited
  );
comment on column xxl_job_log.job_group is '执行器主键ID';
comment on column xxl_job_log.job_id is '任务，主键ID';
comment on column xxl_job_log.executor_address is '执行器地址，本次执行的地址';
comment on column xxl_job_log.executor_handler is '执行器任务handler';
comment on column xxl_job_log.executor_param is '执行器任务参数';
comment on column xxl_job_log.executor_sharding_param is '执行器任务分片参数，格式如 1/2';
comment on column xxl_job_log.executor_fail_retry_count is '失败重试次数';
comment on column xxl_job_log.trigger_time is '调度-时间';
comment on column xxl_job_log.trigger_code is '调度-结果';
comment on column xxl_job_log.trigger_msg is '调度-日志';
comment on column xxl_job_log.handle_time is '执行-时间';
comment on column xxl_job_log.handle_code is '执行-状态';
comment on column xxl_job_log.handle_msg is '执行-日志';
comment on column xxl_job_log.alarm_status is '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败';
alter table xxl_job_log
  add constraint PK_xxl_job_log primary key (ID)
  using index
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
create index IDX_xxl_job_log_time on xxl_job_log (trigger_time)
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
create index IDX_xxl_job_log_handle on xxl_job_log (handle_code)
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
---------------------------------------------------------
--xxl_job_logglue
---------------------------------------------------------
DROP SEQUENCE xxl_job_logglue_id;
CREATE SEQUENCE xxl_job_logglue_id START WITH 100;
SELECT xxl_job_logglue_id.NEXTVAL FROM DUAL;
drop table xxl_job_logglue;
CREATE TABLE xxl_job_logglue (
  id number(11) NOT NULL,
  job_id number(11) NOT NULL ,
  glue_type varchar2(50) DEFAULT NULL ,
  glue_source clob ,
  glue_remark varchar2(128) NOT NULL ,
  add_time date DEFAULT NULL,
  update_time date DEFAULT sysdate
  --update_time date NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 80K
    minextents 1
    maxextents unlimited
  );
comment on column xxl_job_logglue.job_id is '任务，主键ID';
comment on column xxl_job_logglue.glue_type is 'GLUE类型';
comment on column xxl_job_logglue.glue_source is 'GLUE源代码';
comment on column xxl_job_logglue.glue_remark is 'GLUE备注';
alter table xxl_job_logglue
  add constraint PK_xxl_job_logglue primary key (ID)
  using index
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
create or replace trigger xxl_job_logglue_trigger 
  before insert or update on xxl_job_logglue for each row 
  begin 
    select sysdate into :new.update_time from dual;
  end;
/
---------------------------------------------------------
--xxl_job_registry
---------------------------------------------------------
DROP SEQUENCE xxl_job_registry_id;
CREATE SEQUENCE xxl_job_registry_id START WITH 100;
SELECT xxl_job_registry_id.NEXTVAL FROM DUAL;
drop table xxl_job_registry;
CREATE TABLE xxl_job_registry (
  id number(11) NOT NULL ,
  registry_group varchar2(255) NOT NULL,
  registry_key varchar2(255) NOT NULL,
  registry_value varchar2(255) NOT NULL,
  update_time date DEFAULT sysdate
) tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 80K
    minextents 1
    maxextents unlimited
  );
alter table xxl_job_registry
  add constraint PK_xxl_job_registry primary key (ID)
  using index
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
create index IDX_xxl_job_registry_gkv on xxl_job_registry (registry_group,registry_key,registry_value)
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
---------------------------------------------------------
--xxl_job_group
---------------------------------------------------------
DROP SEQUENCE xxl_job_group_id;
CREATE SEQUENCE xxl_job_group_id START WITH 100;
SELECT xxl_job_group_id.NEXTVAL FROM DUAL;
drop table xxl_job_group;
CREATE TABLE xxl_job_group (
  id number(11) NOT NULL,
  app_name varchar2(64) NOT NULL ,
  title varchar2(12) NOT NULL ,
  worder number(4) DEFAULT '0' ,
  address_type number(4) DEFAULT '0' ,
  address_list varchar2(512) DEFAULT NULL 
) tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 80K
    minextents 1
    maxextents unlimited
  );
comment on column xxl_job_group.app_name is '执行器AppName';
comment on column xxl_job_group.title is '执行器名称';
comment on column xxl_job_group.worder is '排序';
comment on column xxl_job_group.address_type is '执行器地址类型：0=自动注册、1=手动录入';
comment on column xxl_job_group.address_list is '执行器地址列表，多地址逗号分隔';
alter table xxl_job_group
  add constraint PK_xxl_job_group primary key (ID)
  using index
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
---------------------------------------------------------
--xxl_job_user
---------------------------------------------------------
DROP SEQUENCE xxl_job_user_id;
CREATE SEQUENCE xxl_job_user_id START WITH 100;
SELECT xxl_job_user_id.NEXTVAL FROM DUAL;
drop table xxl_job_user;
CREATE TABLE xxl_job_user (
  id number(11) NOT NULL ,
  wusername varchar2(50) NOT NULL ,
  password varchar2(50) NOT NULL ,
  role number(4) NOT NULL ,
  permission varchar2(255) DEFAULT NULL 
)tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 80K
    minextents 1
    maxextents unlimited
  );
comment on column xxl_job_user.wusername is '账号';
comment on column xxl_job_user.password is '密码';
comment on column xxl_job_user.role is '角色：0-普通用户、1-管理员';
comment on column xxl_job_user.permission is '权限：执行器ID列表，多个逗号分割';
alter table xxl_job_user
  add constraint PK_xxl_job_user primary key (ID)
  using index
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
create unique index IDX_xxl_job_user_user on xxl_job_user (wusername)
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
---------------------------------------------------------
--xxl_job_lock
---------------------------------------------------------
drop table xxl_job_lock;
CREATE TABLE xxl_job_lock (
  lock_name varchar(50) NOT NULL 
) tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 80K
    minextents 1
    maxextents unlimited
  );
comment on column xxl_job_lock.lock_name is '锁名称';
alter table xxl_job_lock
  add constraint PK_xxl_job_lock primary key (lock_name)
  using index
  tablespace TBS_BIL_ROAM
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

---------------------------------------------------------
--DATA
---------------------------------------------------------
INSERT INTO xxl_job_group(id, app_name, title, "order", address_type, address_list) VALUES (1, 'xxl-job-executor-sample', '示例执行器', 1, 0, NULL);
INSERT INTO xxl_job_info(id, job_group, job_cron, job_desc, add_time, update_time, author, alarm_email, executor_route_strategy, executor_handler, executor_param, executor_block_strategy, executor_timeout, executor_fail_retry_count, glue_type, glue_source, glue_remark, glue_updatetime, child_jobid) VALUES (1, 1, '0 0 0 * * ? *', '测试任务1', to_date('2018-11-03 22:21:31','YYYY-MM-DD HH24:MI:SS'), to_date('2018-11-03 22:21:31','YYYY-MM-DD HH24:MI:SS'), 'XXL', '', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化', to_date('2018-11-03 22:21:31','YYYY-MM-DD HH24:MI:SS'), '');
INSERT INTO xxl_job_user(id, "username", password, role, permission) VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);
INSERT INTO xxl_job_lock ( lock_name) VALUES ( 'schedule_lock');

commit;

