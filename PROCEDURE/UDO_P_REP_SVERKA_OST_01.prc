CREATE OR REPLACE PROCEDURE PARUS.UDO_P_REP_SVERKA_OST_01(PIN_COM      IN NUMBER,
                                                          PIN_D1       IN DATE, --- Первое число месяца
                                                          PIN_MOL      IN VARCHAR2,
                                                          PIN_PBE      IN VARCHAR2,
                                                          PIN_TMC      IN VARCHAR2,
                                                          PIN_LS       IN NUMBER,
                                                          PIN_KOSGU    IN VARCHAR2,
                                                          PIN_GR_TMC   IN VARCHAR2,
                                                          PIN_NO_KOSGU in number,
                                                          PIN_NO_AKP   in number,
                                                          PIN_NO_SR    in number) IS
  ---1 - Только ЛС
  V_SKL VARCHAR2(2000) := ' '; --- Все склады у котрых данные МОЛ

  --- Определяем параметры макроподстановки
  sBLANK     VARCHAR2(20) := GET_OPTIONS_STR('EmptySymb');
  sDELIMITER VARCHAR2(20) := GET_OPTIONS_STR('SeqSymb');
  sStar      VARCHAR2(20) := GET_OPTIONS_STR('StarSymb');
  sQuestSymb VARCHAR2(20) := GET_OPTIONS_STR('QuestSymb');
  sNotSymb   VARCHAR2(20) := GET_OPTIONS_STR('NotSymb');

  s_MOL    VARCHAR2(2000) := REPLACE(REPLACE(PIN_MOL, sStar, '%'),
                                     sQuestSymb,
                                     '_');
  s_PBE    VARCHAR2(2000) := REPLACE(REPLACE(PIN_PBE, sStar, '%'),
                                     sQuestSymb,
                                     '_');
  s_TMC    VARCHAR2(2000) := REPLACE(REPLACE(PIN_TMC, sStar, '%'),
                                     sQuestSymb,
                                     '_');
  s_KOSGU  VARCHAR2(2000) := REPLACE(REPLACE(PIN_KOSGU, sStar, '%'),
                                     sQuestSymb,
                                     '_');
  s_GR_TMC VARCHAR2(2000) := REPLACE(REPLACE(PIN_GR_TMC, sStar, '%'),
                                     sQuestSymb,
                                     '_');

  V_SES NUMBER(17) := userenv('sessionid');
  V_D1  DATE := trunc(PIN_D1, 'Month');

  SH CONSTANT PKG_STD.tSTRING := 'сверка';

  -- шапка отчета
  CELL_ORG_NAME CONSTANT PKG_STD.tSTRING := 'ORG_NAME';
  CELL_DATA_NA  CONSTANT PKG_STD.tSTRING := 'DATA_NA';
  CELL_SKLAD    CONSTANT PKG_STD.tSTRING := 'SKLAD';
  CELL_ZAG_TMC  CONSTANT PKG_STD.tSTRING := 'ZAG_TMC';
  CELL_ZAG_PBE  CONSTANT PKG_STD.tSTRING := 'ZAG_PBE';

  LINE1    CONSTANT PKG_STD.TSTRING := 'LINE1';
  LINE_TMC CONSTANT PKG_STD.TSTRING := 'LINE_TMC';
  LINE_PBE CONSTANT PKG_STD.TSTRING := 'LINE_PBE';

  COL_KOSGU CONSTANT PKG_STD.TSTRING := 'COL_KOSGU';
  COL_AKP CONSTANT PKG_STD.TSTRING := 'COL_AKP';
  COL_SR CONSTANT PKG_STD.TSTRING := 'COL_SR';

  CELL_LINE1_MOL        CONSTANT PKG_STD.TSTRING := 'MOL';
  CELL_LINE1_PBE        CONSTANT PKG_STD.TSTRING := 'PBE';
  CELL_LINE1_NOMEN_CODE CONSTANT PKG_STD.TSTRING := 'NOMEN_CODE';
  CELL_LINE1_NOMEN_NAME CONSTANT PKG_STD.TSTRING := 'NOMEN_NAME';
  CELL_LINE1_BUH_Q      CONSTANT PKG_STD.TSTRING := 'BUH_Q';
  CELL_LINE1_BUH_S      CONSTANT PKG_STD.TSTRING := 'BUH_S';
  CELL_LINE1_SKL_Q      CONSTANT PKG_STD.TSTRING := 'SKL_Q';
  CELL_LINE1_SKL_S      CONSTANT PKG_STD.TSTRING := 'SKL_S';
  CELL_LINE1_DELT_Q     CONSTANT PKG_STD.TSTRING := 'DELT_Q';
  CELL_LINE1_DELT_S     CONSTANT PKG_STD.TSTRING := 'DELT_S';
  CELL_LINE1_KOSGU      CONSTANT PKG_STD.TSTRING := 'KOSGU';
  CELL_LINE1_AKP        CONSTANT PKG_STD.TSTRING := 'CELL_AKP';  
  CELL_LINE1_SR        CONSTANT PKG_STD.TSTRING := 'CELL_SR';  
  --- Итоги
  CELL_ITG_Q CONSTANT PKG_STD.tSTRING := 'ITG_Q';
  CELL_ITG_S CONSTANT PKG_STD.tSTRING := 'ITG_S';

  iLINE_IDX INTEGER;

  V_ITG_Q NUMBER(15, 2) := 0;
  V_ITG_S NUMBER(15, 2) := 0;

BEGIN
  /* пролог */
  PRSG_EXCEL.PREPARE;
  /* установка текущего рабочего листа */
  PRSG_EXCEL.SHEET_SELECT(SH);
  ---- 
  IF s_MOL != '%' THEN
    FOR cur IN (SELECT skl.azs_number SKN
                  FROM parus.azsazslistmt SKL, agnlist MOL
                 WHERE skl.company = PIN_COM
                   AND SKL.AZS_AGENT = mol.rn
                   AND (PIN_MOL IS NULL OR
                       UDO_F_strinlike(MOL.AGNABBR,
                                        s_MOL,
                                        sDELIMITER,
                                        sBLANK,
                                        sNotSymb) = 1)) LOOP
      IF length(V_SKL) < 2000 THEN
        V_SKL := V_SKL || ';' || cur.skn;
      ELSE
      
        V_SKL := '%';
        EXIT; --- Если так много, то по всем     
      END IF;
    
    END LOOP;
  ELSE
    V_SKL := '%';
  END IF;

  --- Сформируем остатки по складу

  if PIN_MOL is not null and V_SKL = ' ' then
    P_EXCEPTION(0,
                'Для МОЛ - ' || PIN_MOL || ' не найдено ни одного склада.');
  end if;
---if user = 'GORODETSKIY' then P_exception(0, V_SKL ); end if;
  PARUS.UDO_P_OBOROT_CREATE(ncompany     => PIN_COM,
                            PIN_SES      => V_SES,
                            PIN_EXP      => 0,
                            dbgn         => V_D1,
                            dend         => V_D1,
                            PIN_STORE    => substr(V_SKL, 2),
                            PIN_NOMEN    => PIN_TMC,
                            PIN_PBE      => PIN_PBE,
                            PIN_GR_LS    => NULL,
                            PIN_GR_NM    => PIN_GR_TMC,
                            PIN_ANL3     => NULL,
                            PIN_ANL4     => PIN_KOSGU,
                            PIN_LAT      => 0,
                            PIN_NO_SER   => 1,
                            PIN_NO_PAR   => 0,
                            PIN_EXP_DATE => 0,
                            PIN_NO_ANL4  => 0,
                            PIN_NO_PBE   => 0,
                            PIN_NO_PRICE => 0);

  PRSG_EXCEL.CELL_DESCRIBE(CELL_ORG_NAME);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_DATA_NA);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_ITG_Q);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_ITG_S);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_SKLAD);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_ZAG_TMC);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_ZAG_PBE);

  PRSG_EXCEL.LINE_DESCRIBE(LINE1);
  PRSG_EXCEL.LINE_DESCRIBE(LINE_PBE);
  PRSG_EXCEL.LINE_DESCRIBE(LINE_TMC);

  PRSG_EXCEL.COLUMN_DESCRIBE(COL_KOSGU);
  PRSG_EXCEL.COLUMN_DESCRIBE(COL_AKP);
  PRSG_EXCEL.COLUMN_DESCRIBE(COL_SR);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_MOL);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_PBE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_NOMEN_CODE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_NOMEN_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_BUH_Q);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_BUH_S);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_SKL_Q);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_SKL_S);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_DELT_Q);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_DELT_S);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_KOSGU);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_AKP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_SR);

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_ORG_NAME,
                              parus.udo_PKG_REP.COMPANY_AGNLIST_NAME(PIN_COM,
                                                                     1));
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_DATA_NA,
                              'По состоянию на ' ||
                              to_char(V_D1, 'DD.MM.YYYY'));
  IF s_MOL = '%' OR V_SKL = '%' THEN
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_SKLAD, 'По всем МОЛ');
  ELSE
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_SKLAD, 'По МОЛ ' || PIN_MOL);
  END IF;

  IF PIN_PBE IS NULL THEN
    PARUS.PRSG_EXCEL.LINE_DELETE(LINE_PBE);
  ELSE
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_ZAG_PBE, 'По ПБЕ : ' || PIN_PBE);
  END IF;

  IF PIN_TMC IS NULL THEN
    PARUS.PRSG_EXCEL.LINE_DELETE(LINE_TMC);
  ELSE
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_ZAG_TMC,
                                'По номенклатурам : ' || PIN_TMC);
  END IF;

  FOR cur IN (SELECT Z.nomen_code,
                     z.nomen_name,
                     Z.MOL,
                     Z.PBE,
                     Z.KOSGU,
                     Z.AKP,
                     Z.SR,
                     SUM(Z.BUH_Q) BUH_Q,
                     SUM(Z.BUH_S) BUH_S,
                     SUM(Z.SKL_Q) SKL_Q,
                     SUM(Z.SKL_S) SKL_S
                FROM ( ---  по бухгалтерскому учету
                      SELECT D.nomen_code,
                              D.nomen_name,
                              MOL.agnabbr MOL,
                              PBE.BUNIT_MNEMO PBE,
                              SUM(ANL.ACNT_REMN_QUANT) BUH_Q,
                              SUM(ANL.ACNT_REMN_BASE_SUM) BUH_S,
                              0 SKL_Q,
                              0 SKL_S,
                              case PIN_NO_KOSGU
                                when 0 then
                                 REPLACE(REPLACE(KOSGU.ANL_NUMBER, '_2016', ''),
                                         '_2017',
                                         '')
                                else
                                 ''
                              end KOSGU,
                             case PIN_NO_AKP
                               when 0 then AKP.ANL_NUMBER
                                 else null end AKP ,
                             case PIN_NO_SR when 0 then substr(S.ACC_NUMBER,1,14)
                               else null end SR      
                        FROM PARUS.VALREMNS    ostB,
                              parus.DICBUNTS    PBE,
                              PARUS.AGNLIST     MOL,
                              parus.VALREMNSANL ANL,                             
                              parus.dicanls     KOSGU,
                              parus.dicanls     AKP,
                              parus.dicnomns    D,
                              parus.Dicgnomn    GRN,
                              DICACCS S
                       WHERE OSTB.COMPANY = PIN_COM
                         AND OSTB.REMN_DATE = V_D1
                         AND (ostB.ACNT_REMN_QUANT != 0 OR
                             ostB.Acnt_Remn_Base_Sum != 0)
                         AND (PIN_LS = 0 OR
                             parus.udo_PKG_REP.NOMEN_IS_DRUG(PIN_COM,
                                                              OSTB.NOMENCLATURE) = 1) --- Только лекарственные средства
                         AND OSTB.balunit = pbe.rn(+)
                         AND (PIN_PBE IS NULL OR
                             strinlike(PBE.BUNIT_MNEMO,
                                        s_PBE,
                                        sDELIMITER,
                                        sBLANK) = 1 OR OSTB.balunit IS NULL)
                         AND OSTB.AGENT = MOL.Rn
                         AND ANL.prn = OSTB.rn
                         AND ANL.Analytic1 = AKP.rn(+)
                         AND ANL.Analytic4 = KOSGU.rn(+)
                         AND (PIN_MOL IS NULL OR
                             parus.strinlike(MOL.agnabbr,
                                              S_MOL,
                                              sDELIMITER,
                                              sBLANK) = 1)
                         AND (PIN_KOSGU IS NULL OR
                             strinlike(KOSGU.ANL_NUMBER,
                                        s_KOSGU,
                                        sDELIMITER,
                                        sBLANK) = 1)
                         AND OSTB.Nomenclature = D.rn
                         AND (PIN_TMC IS NULL OR
                             strinlike(D.nomen_code,
                                        s_TMC,
                                        sDELIMITER,
                                        sBLANK) = 1)
                         AND D.GROUP_CODE = GRN.rn
                         AND (PIN_GR_TMC IS NULL OR
                             strinlike(GRN.GROUP_CODE,
                                        s_GR_TMC,
                                        sDELIMITER,
                                        sBLANK) = 1)
                         and ostB.Account = s.rn               
                       GROUP BY D.nomen_code,
                                 D.nomen_name,
                                 MOL.agnabbr,
                                 PBE.BUNIT_MNEMO,
                                 KOSGU.ANL_NUMBER,
                                 AKP.ANL_NUMBER,
                                 substr(S.ACC_NUMBER,1,14)
                      UNION ALL
                      --- по складу
                      SELECT osts.nomen_code,
                             d.nomen_name nomen_name, -- Здесь было osts.MODIF_name. а в выборке сверху nomen_name. 02.08.22 Дубровин Е.Ю.
                             MOL.AGNABBR MOL,
                             OSTS.PBE,
                             0 BUH_Q,
                             0 BUH_S,
                             osts.ost_q_beg SKL_Q,
                             osts.ost_sum_beg SKL_S,
                             case PIN_NO_KOSGU
                               when 0 then
                                OSTS.Anl4
                               else
                                ''
                             end KOSGU,
                             case PIN_NO_AKP when 0 then UDO_F_RETURN_GOODSPARTIES_AKP(NRN => OSTS.GPRN, NCOMPANY => PIN_COM)
                               else null end AKP,
                             case PIN_NO_SR when 0 then substr(udo_f_return_goodsparties_sr(NRN => OSTS.GPRN, NCOMPANY => PIN_COM),4, 14)
                               else null end SR    
                        FROM parus.UDO_TAB_OBOROT_CREATE OSTS,
                             parus.azsazslistmt          SKL,
                             agnlist                     MOL,
                             dicnomns d  
                       WHERE ostS.SUSER = USER
                         AND OSTS.COMPANY = PIN_COM
                         AND OSTS.NSESS = V_SES
                         AND (OSTS.OST_Q_BEG != 0 OR ostS.Ost_Sum_Beg != 0)
                         AND (PIN_LS = 0 OR
                             parus.udo_PKG_REP.NOMEN_IS_DRUG(PIN_COM,
                                                              OSTS.NOM_RN) = 1) --- Только лекарственные средства
                         AND OSTS.AZS_RN = skl.rn
                         AND MOL.rn = skl.azs_agent
                         AND d.rn=osts.nom_rn) Z
               GROUP BY Z.nomen_code, Z.nomen_name, Z.MOL, Z.PBE, Z.KOSGU, Z.AKP, Z.SR
              HAVING(SUM(Z.BUH_Q) != SUM(Z.SKL_Q) OR SUM(Z.BUH_S) != SUM(Z.SKL_S))
               ORDER BY Z.Nomen_CODE, Z.MOL) LOOP
  
    iLINE_IDX := PRSG_EXCEL.Line_append(LINE1);
  
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_MOL, 0, iLINE_IDX, cur.MOL);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_PBE, 0, iLINE_IDX, cur.PBE);
    if PIN_NO_KOSGU = 0 then 
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_KOSGU, 0, iLINE_IDX, cur.KOSGU);
    end if;
    if PIN_NO_AKP = 0 then
       PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_AKP, 0, iLINE_IDX, cur.AKP);
    end if;
    
    if PIN_NO_SR = 0 then
       PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_SR, 0, iLINE_IDX, cur.SR);
    end if;
    
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_NOMEN_CODE,
                                0,
                                iLINE_IDX,
                                cur.NOMEN_CODE);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_NOMEN_NAME,
                                0,
                                iLINE_IDX,
                                cur.NOMEN_NAME);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_BUH_Q, 0, iLINE_IDX, cur.BUH_Q);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_BUH_S, 0, iLINE_IDX, cur.BUH_S);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_SKL_Q, 0, iLINE_IDX, cur.SKL_Q);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_SKL_S, 0, iLINE_IDX, cur.SKL_S);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_DELT_Q,
                                0,
                                iLINE_IDX,
                                cur.BUH_Q - cur.SKL_Q);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_DELT_S,
                                0,
                                iLINE_IDX,
                                cur.BUH_S - cur.SKL_S);
    V_ITG_Q := V_ITG_Q + cur.BUH_Q - cur.SKL_Q;
    V_ITG_S := V_ITG_S + cur.BUH_S - cur.SKL_S;
  END LOOP;
  PARUS.PRSG_EXCEL.LINE_DELETE(LINE1);

  if PIN_NO_KOSGU = 1 then
    prsg_excel.COLUMN_DELETE(COL_KOSGU);
  end if;
  
  if PIN_NO_AKP = 1 then
    prsg_excel.COLUMN_DELETE(COL_AKP);
  end if;
  
  if PIN_NO_SR = 1 then
    prsg_excel.COLUMN_DELETE(COL_SR);
  end if;

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_ITG_Q, V_ITG_Q);
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_ITG_S, V_ITG_S);

END;
/*
  grant execute on  parus.UDO_P_REP_SVERKA_OST_01 to public;
  */
/
