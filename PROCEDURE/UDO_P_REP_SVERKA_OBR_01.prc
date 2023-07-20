create or replace procedure parus.UDO_P_REP_SVERKA_OBR_01(PIN_COM in number,
                                                          PIN_D1  in date,
                                                          PIN_D2  in date,
                                                          PIN_MOL in varchar2,
                                                          PIN_TMC in varchar2) is

  --- Определяем параметры макроподстановки
  sBLANK     varchar2(20) := GET_OPTIONS_STR('EmptySymb');
  sDELIMITER varchar2(20) := GET_OPTIONS_STR('SeqSymb');
  sStar      varchar2(20) := GET_OPTIONS_STR('StarSymb');
  sQuestSymb varchar2(20) := GET_OPTIONS_STR('QuestSymb');

  iLINE_IDX integer;

  -- МОЛ товарного отчета
  s_MOL Varchar2(2000) := replace(replace(PIN_MOL, sStar, '%'), sQuestSymb, '_');
  -- Номенклатура Товарного отчета
  s_TMC Varchar2(2000) := replace(replace(PIN_TMC, sStar, '%'), sQuestSymb, '_');

  SH constant PKG_STD.tSTRING := 'сверка движения';

  CELL_ORG_NAME constant PKG_STD.tSTRING := 'ORG_NAME';
  CELL_PERIOD   constant PKG_STD.tSTRING := 'PERIOD';

  LINE1        constant PKG_STD.TSTRING := 'LINE1';
  LINE_ITG_MOL constant PKG_STD.TSTRING := 'LINE_ITG_MOL';
  LINE_HO      constant PKG_STD.TSTRING := 'LINE_HO';
  LINE_HOZ     constant PKG_STD.TSTRING := 'LINE_HOZ';
  LINE_HO1     constant PKG_STD.TSTRING := 'LINE_HO1';

  CELL_LINE1_NMB     constant PKG_STD.TSTRING := 'TR_NMB';
  CELL_LINE1_DATE    constant PKG_STD.TSTRING := 'TR_DATE';
  CELL_LINE1_MOL     constant PKG_STD.TSTRING := 'TR_MOL';
  CELL_LINE1_NOM     constant PKG_STD.TSTRING := 'TR_NOM';
  CELL_LINE1_Q       constant PKG_STD.TSTRING := 'TR_Q';
  CELL_LINE1_S       constant PKG_STD.TSTRING := 'TR_S';
  CELL_LINE1_HO_NMB  constant PKG_STD.TSTRING := 'HO_NMB';
  CELL_LINE1_HO_DATE constant PKG_STD.TSTRING := 'HO_DATE';
  CELL_LINE1_HO_MOL  constant PKG_STD.TSTRING := 'HO_MOL';
  CELL_LINE1_HO_NOM  constant PKG_STD.TSTRING := 'HO_NOM';
  CELL_LINE1_HO_Q    constant PKG_STD.TSTRING := 'HO_Q';
  CELL_LINE1_HO_S    constant PKG_STD.TSTRING := 'HO_S';

  CELL_LINEHO_L2PBE  constant PKG_STD.TSTRING := 'L2PBE';
  CELL_LINEHO_L2DB   constant PKG_STD.TSTRING := 'L2DB';
  CELL_LINEHO_L2KR   constant PKG_STD.TSTRING := 'L2KR';
  CELL_LINEHO_L2DATE constant PKG_STD.TSTRING := 'L2DATE';
  CELL_LINEHO_L2NMB  constant PKG_STD.TSTRING := 'L2NMB';
  CELL_LINEHO_L2Q    constant PKG_STD.TSTRING := 'L2Q';
  CELL_LINEHO_L2S    constant PKG_STD.TSTRING := 'L2S';
  CELL_LINEHO_L2FROM constant PKG_STD.TSTRING := 'L2FROM';
  CELL_LINEHO_L2TO   constant PKG_STD.TSTRING := 'L2TO';

begin
  /* пролог */
  PRSG_EXCEL.PREPARE;
  /* установка текущего рабочего листа */
  PRSG_EXCEL.SHEET_SELECT(SH);

  PRSG_EXCEL.CELL_DESCRIBE(CELL_ORG_NAME);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_PERIOD);

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_ORG_NAME, parus.udo_PKG_REP.COMPANY_AGNLIST_NAME(PIN_COM, 1));
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_PERIOD, 'C ' || to_char(PIN_D1, 'DD.MM.YYYY') || ' по ' || to_char(PIN_D2, 'DD.MM.YYYY'));

  PRSG_EXCEL.LINE_DESCRIBE(LINE1);
  PRSG_EXCEL.LINE_DESCRIBE(LINE_ITG_MOL);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_NMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_MOL);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_NOM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_Q);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_S);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_HO_NMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_HO_DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_HO_MOL);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_HO_NOM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_HO_Q);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1, CELL_LINE1_HO_S);

  PRSG_EXCEL.LINE_DESCRIBE(LINE_HO);
  PRSG_EXCEL.LINE_DESCRIBE(LINE_HOZ);
  PRSG_EXCEL.LINE_DESCRIBE(LINE_HO1);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_HO1, CELL_LINEHO_L2PBE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_HO1, CELL_LINEHO_L2DB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_HO1, CELL_LINEHO_L2KR);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_HO1, CELL_LINEHO_L2DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_HO1, CELL_LINEHO_L2NMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_HO1, CELL_LINEHO_L2Q);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_HO1, CELL_LINEHO_L2S);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_HO1, CELL_LINEHO_L2FROM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_HO1, CELL_LINEHO_L2TO);

  for cur in (
              /* Тип складской операции (0 - расход, 1 - приход) */
              select trim(nvl2(T.RPT_PREFIX, T.RPT_PREFIX || '-', '')) || trim(T.Rpt_Number) TR_NMB,
                      to_char(T.Rpt_Date, 'DD.MM.YYYY') TR_DATE,
                      MOL_TR.Agnabbr TR_MOL,
                      decode(op.gsmways_type, 0, Hs_TO.agnabbr, HS_From.agnabbr) HS_MOL,
                      TS.QUANTITY_MAIN TR_Q_OEI,
                      TS.REG_SUM_BASE TR_S,
                      trim(nvl2(H.OPERATION_PREF, H.OPERATION_PREF || '-', '')) || trim(H.Operation_Numb) H_NMB,
                      to_char(H.OPERATION_DATE, 'DD.MM.YYYY') H_DATE,
                      decode(op.gsmways_type, 0, Hs_TO.agnabbr, HS_From.agnabbr) H_MOL,
                      HS.ACNT_QUANT H_Q,
                      HS.ACNT_BASE_SUM H_S,
                      TR_D.Nomen_Code TR_NOMEN,
                      HS_D.NOMEN_CODE H_NOMEN
                from parus.SALESREPORTMAIN   T,
                      parus.SALESREPORTDETAIL TS,
                      parus.AZSGSMWAYSTYPES   OP,
                      parus.doclinks          L,
                      parus.OPRSPECS          HS,
                      parus.agnlist           MOL_TR,
                      parus.agnlist           HS_TO,
                      parus.agnlist           HS_FROM,
                      parus.dicnomns          TR_D,
                      parus.Dicnomns          HS_D,
                      parus.econoprs          H
               where T.Company = PIN_COM
                 and T.Rpt_Date between PIN_D1 and PIN_D2
                 and T.rn = ts.prn
                 and TS.Oper_Code = op.rn
                 and L.In_Document = TS.rn
                 and L.Out_Unitcode = 'EconomicOperationsSpecs'
                 and L.Out_Company = PIN_COM
                 and L.In_Unitcode = 'TradeReportsSp'
                 and L.In_Company = L.Out_Company
                 and hs.rn = L.Out_Document
                 and HS.Nomenclature is not null
                 and (MOL_TR.Agnabbr != decode(op.gsmways_type, 0, Hs_TO.agnabbr, HS_From.agnabbr) or TS.QUANTITY_MAIN != HS.ACNT_QUANT or
                     HS.ACNT_BASE_SUM != TS.REG_SUM_BASE or TS.Nomenclature != HS.NOMENCLATURE)
                 and T.agent = MOL_TR.rn
                 and (PIN_MOL is null or strinlike(MOL_TR.AGNABBR, s_MOL, sDELIMITER, sBLANK) = 1)
                 and (PIN_TMC is null or strinlike(TR_D.Nomen_Code, s_TMC, sDELIMITER, sBLANK) = 1)
                 and HS.VALUES_FROM = HS_TO.rn(+)
                 and HS.VALUES_TO = HS_FROM.rn(+)
                 and TR_D.rn = ts.nomenclature
                 and HS_D.rn = hs.nomenclature
                 and H.rn = HS.Prn
               order by MOL_TR.Agnabbr, TR_D.Nomen_Code)
  
   loop
  
    iLINE_IDX := PRSG_EXCEL.Line_append(LINE1);
  
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_NMB, 0, iLINE_IDX, cur.TR_NMB);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_DATE, 0, iLINE_IDX, cur.TR_DATE);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_MOL, 0, iLINE_IDX, cur.TR_MOL);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_NOM, 0, iLINE_IDX, cur.TR_NOMEN);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_Q, 0, iLINE_IDX, cur.TR_Q_OEI);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_S, 0, iLINE_IDX, cur.TR_S);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_HO_NMB, 0, iLINE_IDX, cur.H_NMB);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_HO_DATE, 0, iLINE_IDX, cur.H_DATE);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_HO_MOL, 0, iLINE_IDX, cur.H_MOL);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_HO_NOM, 0, iLINE_IDX, cur.H_NOMEN);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_HO_Q, 0, iLINE_IDX, cur.H_Q);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINE1_HO_S, 0, iLINE_IDX, cur.H_S);
  
    ---   PRSG_EXCEL.CELL_FORMULA_WRITE(sCELL_LINEGR1_SUMMBUDG,0, iLEVEL_INDEXES(i), '=ПРОМЕЖУТОЧНЫЕ.ИТОГИ(9;R[2]C:R['|| to_char(1 + iLEVEL_SUBINDEXES(i))|| ']C)'   );
  
    if cur.H_Q != cur.TR_Q_OEI then
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(CELL_LINE1_HO_Q, 0, iLINE_IDX, 'Interior.ColorIndex', 35);
    end if;
  
    if cur.H_S != cur.TR_S then
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(CELL_LINE1_HO_S, 0, iLINE_IDX, 'Interior.ColorIndex', 35);
    end if;
  
    if cur.TR_NOMEN != cur.H_NOMEN then
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(CELL_LINE1_HO_NOM, 0, iLINE_IDX, 'Interior.ColorIndex', 35);
    end if;
  
    if cur.TR_NOMEN != cur.H_NOMEN then
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(CELL_LINE1_HO_NOM, 0, iLINE_IDX, 'Interior.ColorIndex', 35);
    end if;
    
     if cur.TR_MOL != cur.H_MOL then
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(CELL_LINE1_HO_MOL, 0, iLINE_IDX, 'Interior.ColorIndex', 35);
    end if;
  
  end loop;

  PARUS.PRSG_EXCEL.LINE_DELETE(LINE1);

  for cur in (
              
              select PBE.BUNIT_MNEMO PBE,
                      DB.Acc_Number DB,
                      KR.Acc_Number KR,
                      HS.ACNT_BASE_SUM S,
                      HS.ACNT_QUANT Q,
                      trim(nvl2(H.OPERATION_PREF, H.OPERATION_PREF || '-', '')) || trim(H.Operation_Numb) H_NMB,
                      to_char(H.OPERATION_DATE, 'DD.MM.YYYY') HDATE,
                      AFR.AGNABBR F,
                      ATO.Agnabbr T
                from parus.OPRSPECS HS,
                      parus.dicnomns D,
                      (select L.OUT_DOCUMENT RN
                         from parus.doclinks L
                        where L.In_Unitcode = 'TradeReports'
                          and l.out_unitcode = 'EconomicOperationsSpecs'
                          and L.In_Company = PIN_COM
                          and L.Out_Company = L.In_Company) LL,
                      parus.ECONOPRS H,
                      parus.agnlist AFR,
                      parus.agnlist ATO,
                      parus.dicaccs DB,
                      parus.dicaccs KR,
                      parus.dicbunts PBE
               where HS.Company = PIN_COM
                 and HS.Operation_Date between PIN_D1 and PIN_D2
                 and parus.udo_PKG_REP.NOMEN_IS_DRUG(HS.Company, HS.Nomenclature) = 1 --- Это лекарства
                 and (PIN_MOL is null or strinlike(AFR.AGNABBR, s_MOL, sDELIMITER, sBLANK) = 1 or strinlike(ATO.Agnabbr, s_MOL, sDELIMITER, sBLANK) = 1)
                 and (PIN_TMC is null or strinlike(D.Nomen_Code, s_TMC, sDELIMITER, sBLANK) = 1)
                 and D.rn = HS.Nomenclature
                 and hs.rn = ll.rn(+)
                 and ll.rn is null
                 and H.rn = HS.prn
                 and H.AGENT_FROM = AFR.rn(+)
                 and H.AGENT_TO = ATO.rn(+)
                 and db.rn(+) = HS.Account_Debit
                 and KR.rn(+) = HS.Account_Credit
                 and HS.BALUNIT_DEBIT = pbe.rn
               order by AFR.AGNABBR, ATO.Agnabbr, trim(nvl2(H.OPERATION_PREF, H.OPERATION_PREF || '-', '')) || trim(H.Operation_Numb))
  
   loop
  
    iLINE_IDX := PRSG_EXCEL.Line_append(LINE_HO1);
  
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINEHO_L2PBE, 0, iLINE_IDX, cur.PBE);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINEHO_L2DB, 0, iLINE_IDX, cur.DB);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINEHO_L2KR, 0, iLINE_IDX, cur.KR);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINEHO_L2DATE, 0, iLINE_IDX, cur.HDATE);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINEHO_L2NMB, 0, iLINE_IDX, cur.H_NMB);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINEHO_L2Q, 0, iLINE_IDX, cur.Q);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINEHO_L2S, 0, iLINE_IDX, cur.S);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINEHO_L2FROM, 0, iLINE_IDX, cur.F);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_LINEHO_L2TO, 0, iLINE_IDX, cur.T);
  end loop;

end;
/*
  grant execute on PARUS.UDO_P_REP_SVERKA_OBR_01 to public;
  */
/
