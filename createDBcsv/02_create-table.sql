\c timeline;

-- 暗号化機能を導入
CREATE EXTENSION PGCRYPTO;

-- マスタ関連

-- ユーザテーブル
CREATE TABLE public.m_user
(
    user_id integer NOT NULL,
    user_pw bytea NOT NULL,
    user_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    organization_id integer NOT NULL,
    role_id integer,
    permission_level integer NOT NULL,
    CONSTRAINT m_user_pkey PRIMARY KEY (user_id)
)

TABLESPACE pg_default;

ALTER TABLE public.m_user
    OWNER to postgres;


-- 組織テーブル
CREATE TABLE public.m_organization
(
    organization_id integer NOT NULL,
    organization_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    organization_sub_name character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT m_organization_pkey PRIMARY KEY (organization_id)
)

TABLESPACE pg_default;

ALTER TABLE public.m_organization
    OWNER to postgres;


-- グループテーブル
CREATE TABLE public.m_group
(
    group_id integer NOT NULL,
    group_name character varying(24) COLLATE pg_catalog."default" NOT NULL,
    group_short_name character varying(24) COLLATE pg_catalog."default" NOT NULL,
    group_name_eng character varying(16) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT m_group_pkey PRIMARY KEY (group_id)
)

TABLESPACE pg_default;

ALTER TABLE public.m_group
    OWNER to postgres;


-- 役割テーブル
CREATE TABLE public.m_role
(
    role_id integer NOT NULL,
    group_id integer NOT NULL,
    role_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT m_role_pkey PRIMARY KEY (role_id),
    CONSTRAINT m_role_group_id_fkey FOREIGN KEY (group_id)
        REFERENCES public.m_group (group_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.m_role
    OWNER to postgres;


-- 組織役割マップテーブル
CREATE TABLE public.m_organization_role_map
(
    role_id integer NOT NULL,
    organization_id integer NOT NULL,
    CONSTRAINT m_organization_role_map_pkey PRIMARY KEY (role_id, organization_id),
    CONSTRAINT m_organization_role_map_organization_id_fkey FOREIGN KEY (organization_id)
        REFERENCES public.m_organization (organization_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT m_organization_role_map_role_id_fkey FOREIGN KEY (role_id)
        REFERENCES public.m_role (role_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.m_organization_role_map
    OWNER to postgres;


-- ステージマスタ
CREATE TABLE public.m_stage
(
    stage_id integer NOT NULL,
    stage_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    detail character varying(20) COLLATE pg_catalog."default",
    target character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT m_stage_pkey PRIMARY KEY (stage_id)
)

TABLESPACE pg_default;

ALTER TABLE public.m_stage
    OWNER to postgres;


-- ステージ詳細マスタ
CREATE TABLE public.m_stage_phase
(
    phase_id integer NOT NULL,
    stage_id integer NOT NULL,
    phase_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT m_stage_phase_pkey PRIMARY KEY (phase_id),
    CONSTRAINT m_stage_phase_stage_id_fkey FOREIGN KEY (stage_id)
        REFERENCES public.m_stage (stage_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.m_stage_phase
    OWNER to postgres;


-- タスクマスタ
CREATE TABLE public.m_task
(
    task_id bigint NOT NULL,
    role_id integer NOT NULL,
    organization_id integer NOT NULL,
    stage_id integer NOT NULL,
    phase_id integer NOT NULL,
    task_detail character varying(300) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT m_task_pkey PRIMARY KEY (task_id)
)

TABLESPACE pg_default;

ALTER TABLE public.m_task
    OWNER to postgres;


-- データ関連
-- ログイン状態テーブル
CREATE TABLE public.d_login
(
    sess_key character varying(64) COLLATE pg_catalog."default" NOT NULL,
    user_id integer NOT NULL,
    login_time timestamp without time zone NOT NULL,
    operate_time timestamp without time zone NOT NULL,
    CONSTRAINT d_login_pkey PRIMARY KEY (sess_key),
    CONSTRAINT d_login_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.m_user (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.d_login
    OWNER to postgres;



-- タイムライン
CREATE SEQUENCE public.d_timeline_timeline_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.d_timeline_timeline_id_seq
    OWNER TO postgres;

CREATE TABLE public.d_timeline
(
    timeline_id integer NOT NULL DEFAULT nextval('d_timeline_timeline_id_seq'::regclass),
    timeline_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    start_date timestamp(6) with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_date timestamp(6) with time zone,
    active boolean NOT NULL DEFAULT true,
    practice boolean NOT NULL DEFAULT false,
    CONSTRAINT d_timeline_pkey PRIMARY KEY (timeline_id)
)

TABLESPACE pg_default;

ALTER TABLE public.d_timeline
    OWNER to postgres;


-- ステージ履歴
CREATE SEQUENCE public.d_stage_history_stage_history_id_seq
    INCREMENT 1
    START 55
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.d_stage_history_stage_history_id_seq
    OWNER TO postgres;

CREATE TABLE public.d_stage_history
(
    stage_history_id integer NOT NULL DEFAULT nextval('d_stage_history_stage_history_id_seq'::regclass),
    timeline_id integer NOT NULL,
    detail character varying(500) COLLATE pg_catalog."default",
    update_time timestamp(0) with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_user character varying(100) COLLATE pg_catalog."default",
    update_user_organization character varying(100) COLLATE pg_catalog."default",
    stage_name character varying(20) COLLATE pg_catalog."default",
    stage_detail character varying(20) COLLATE pg_catalog."default",
    stage_target character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT d_stage_history_pkey PRIMARY KEY (stage_history_id),
    CONSTRAINT d_stage_history_timeline_id_fkey FOREIGN KEY (timeline_id)
        REFERENCES public.d_timeline (timeline_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.d_stage_history
    OWNER to postgres;


-- タスク状態
CREATE SEQUENCE public.d_task_status_task_status_id_seq
    INCREMENT 1
    START 829
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.d_task_status_task_status_id_seq
    OWNER TO postgres;

CREATE TABLE public.d_task_status
(
    task_status_id integer NOT NULL DEFAULT nextval('d_task_status_task_status_id_seq'::regclass),
    timeline_id integer NOT NULL,
    task_id bigint NOT NULL,
    group_name character varying(24) COLLATE pg_catalog."default" NOT NULL,
    role_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    organization_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    organization_sub_name character varying(100) COLLATE pg_catalog."default",
    stage_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    stage_detail character varying(20) COLLATE pg_catalog."default" NOT NULL,
    task_detail character varying(300) COLLATE pg_catalog."default" NOT NULL,
    task_status integer NOT NULL DEFAULT 0,
    phase_id integer NOT NULL,
    update_user character varying(100) COLLATE pg_catalog."default",
    group_short_name character varying(24) COLLATE pg_catalog."default",
    group_name_eng character varying(24) COLLATE pg_catalog."default",
    update_time timestamp with time zone,
    CONSTRAINT d_task_status_pkey PRIMARY KEY (task_status_id),
    CONSTRAINT d_task_status_timeline_id_fkey FOREIGN KEY (timeline_id)
        REFERENCES public.d_timeline (timeline_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.d_task_status
    OWNER to postgres;


-- タスク更新履歴（掲示板書き込み）
CREATE SEQUENCE public.d_talk_talk_id_seq
    INCREMENT 1
    START 57
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.d_talk_talk_id_seq
    OWNER TO postgres;

CREATE TABLE public.d_talk
(
    talk_id integer NOT NULL DEFAULT nextval('d_talk_talk_id_seq'::regclass),
    timeline_id integer NOT NULL,
    auther_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    group_name character varying(24) COLLATE pg_catalog."default" NOT NULL,
    role_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    post_time timestamp(0) with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content character varying(500) COLLATE pg_catalog."default" NOT NULL,
    auther_organization character varying(100) COLLATE pg_catalog."default" NOT NULL,
    group_name_eng character varying(24) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT d_talk_pkey PRIMARY KEY (talk_id),
    CONSTRAINT d_talk_timeline_id_fkey FOREIGN KEY (timeline_id)
        REFERENCES public.d_timeline (timeline_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.d_talk
    OWNER to postgres;


-- お知らせ
CREATE SEQUENCE public.d_notice_notice_id_seq
    INCREMENT 1
    START 35
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.d_notice_notice_id_seq
    OWNER TO postgres;

CREATE TABLE public.d_notice
(
    notice_id integer NOT NULL DEFAULT nextval('d_notice_notice_id_seq'::regclass),
    timeline_id integer NOT NULL,
    auther_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    post_time timestamp(0) with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content character varying(500) COLLATE pg_catalog."default" NOT NULL,
    auther_organization character varying(100) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT d_notice_pkey PRIMARY KEY (notice_id),
    CONSTRAINT d_notice_timeline_id_fkey FOREIGN KEY (timeline_id)
        REFERENCES public.d_timeline (timeline_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.d_notice
    OWNER to postgres;

