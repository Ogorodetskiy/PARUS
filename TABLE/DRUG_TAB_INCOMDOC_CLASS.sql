-- Create table
create table PARUS.DRUG_TAB_INCOMDOC_CLASS
(
  company   NUMBER(17),
  prn       NUMBER(17) not null,
  balunit   NUMBER(17),
  expstruct NUMBER(17),
  econclass NUMBER(17),
  akp       VARCHAR2(255),
  kod_subs  VARCHAR2(255),
  vid_post  VARCHAR2(255),
  bkd_code  VARCHAR2(255),
  doc_date  DATE,
  sbranch   VARCHAR2(255)
)
--
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column PARUS.DRUG_TAB_INCOMDOC_CLASS.prn
  is 'RN таблицы INCOMDOC';
comment on column PARUS.DRUG_TAB_INCOMDOC_CLASS.bkd_code
  is 'CODE таблицы incomeclass';
comment on column PARUS.DRUG_TAB_INCOMDOC_CLASS.doc_date
  is 'Дата документа из спецификации ГК "Товары и услуги" (определяет дату (квартал( финансирования';
comment on column PARUS.DRUG_TAB_INCOMDOC_CLASS.sbranch
  is 'Филиал (свойство)';
-- Create/Recreate indexes 
create index PARUS.IDX_BALUNIT_FK on PARUS.DRUG_TAB_INCOMDOC_CLASS (BALUNIT)
  --
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index PARUS.PART_CLASS_COMP on PARUS.DRUG_TAB_INCOMDOC_CLASS (COMPANY)
  --
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create unique index PARUS.PART_CLASS_PRN on PARUS.DRUG_TAB_INCOMDOC_CLASS (PRN)
  --
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table PARUS.DRUG_TAB_INCOMDOC_CLASS
  add constraint PART_CLASS_KEY_PRN primary key (PRN);
alter table PARUS.DRUG_TAB_INCOMDOC_CLASS
  add constraint PART_CLASS_BALUNIT foreign key (BALUNIT)
  references PARUS.DICBUNTS (RN);
