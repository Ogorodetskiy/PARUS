CREATE OR REPLACE PROCEDURE PARUS.DRUG_P_CHECK_UCHET(PIN_SCOM IN VARCHAR2, PIN_D1 IN DATE, PIN_D2 IN DATE, pin_DRUG IN NUMBER, PIN_TMC IN VARCHAR2) IS

  V_SES NUMBER(17) := userenv('sessionid');

  --- Определяем параметры макроподстановки
  sBLANK     VARCHAR2(20) := GET_OPTIONS_STR('EmptySymb');
  sDELIMITER VARCHAR2(20) := GET_OPTIONS_STR('SeqSymb');
  sStar      VARCHAR2(20) := GET_OPTIONS_STR('StarSymb');
  sQuestSymb VARCHAR2(20) := GET_OPTIONS_STR('QuestSymb');
  sNotSymb   VARCHAR2(20) := GET_OPTIONS_STR('NotSymb');

  S_COMPANY VARCHAR2(2000) := REPLACE(REPLACE(PIN_SCOM, sStar, '%'), sQuestSymb, '_'); --- Заменяем Парусные символы макроподстановок на Оракловые;
  S_TMC     VARCHAR2(2000) := REPLACE(REPLACE(PIN_TMC, sStar, '%'), sQuestSymb, '_');

  /* описание отчета */
  -- рабочий лист 
  ch CONSTANT PKG_STD.tSTRING := '1';

  LINE1    CONSTANT PKG_STD.tSTRING := 'LINE1';
  LINE_ORG CONSTANT PKG_STD.tSTRING := 'LINE_ORG';
  LINE_VID CONSTANT PKG_STD.tSTRING := 'LINE_VID';
  LINE_D1  CONSTANT PKG_STD.tSTRING := 'LINE_D1';
  LINE_D2  CONSTANT PKG_STD.tSTRING := 'LINE_D2';
  LINE_TMC CONSTANT PKG_STD.tSTRING := 'LINE_TMC';

  V_FL_org INTEGER := 0;
  V_ORG    parus.companies.name%TYPE := '####';
  ---V_FL_VID integer;
  V_VID VARCHAR2(80) := '#';

  nLineIndex INTEGER;

BEGIN

  DELETE PARUS.DRUG_TAB_SOOTV_Q_AND_S t
   WHERE T.SAUTHID = USER
     AND T.SESID = V_SES;

  prsg_excel.prepare;
  prsg_excel.SHEET_SELECT(CH);

  parus.prsg_excel.CELL_DESCRIBE('PO_TMC');
  parus.prsg_excel.CELL_DESCRIBE('ZA_PERIOD');
  parus.prsg_excel.CELL_DESCRIBE('ZAG_ORG');

  parus.prsg_excel.CELL_VALUE_WRITE('ZA_PERIOD', 'За период с ' || to_char(PIN_D1, 'DD.MM.YYYY') || ' по ' || to_char(PIN_D2, 'DD.MM.YYYY'));
  parus.prsg_excel.CELL_VALUE_WRITE('ZAG_ORG', PIN_SCOM);

  prsg_excel.Line_describe(LINE_D1);
  prsg_excel.Line_describe(LINE_TMC);
  prsg_excel.Line_describe(LINE_D2);
  prsg_excel.Line_describe(LINE1);
  prsg_excel.Line_describe(LINE_ORG);
  prsg_excel.line_cell_describe(LINE_ORG, 'ORG_NAME');
  prsg_excel.Line_describe(LINE_VID);
  prsg_excel.line_cell_describe(LINE_VID, 'VID_RAZD');

  FOR nLineIndex IN 1 .. 20 LOOP
    prsg_excel.line_cell_describe(LINE1, 'CELL' || TO_CHAR(nLineIndex));
  END LOOP;

  ---- Приходные ордера
  INSERT INTO PARUS.DRUG_TAB_SOOTV_Q_AND_S t
    (SELECT USER SAUTHID,
            V_SES SESID,
            '01 Приходные ордера' VID,
            T.Company,
            C.name,
            NM.Modif_Code,
            TS.NOMMODIF,
            TS.NOMNMODIFPACK,
            SUM(TS.FACTQUANT) N_Q,
            SUM(TS.FACTSUMTAX) N_S,
            SUM(SRD1.QUANTITY_MAIN) TR_Q,
            SUM(SRD1.PRSUMM_CUR) TR_S,
            DT.Doccode N_TYPE,
            TRIM(T.INDOCPREF) N_PRF,
            TRIM(T.INDOCNUMB) N_NUMB,
            T.INDOCDATE N_date,
            T.rn N_RN,
            TRIM(SR1.RPT_PREFIX) TR_PRF,
            TRIM(sr1.rpt_number) TR_NMB,
            SRD1.rn tr_rn,
            sr1.rpt_date TR_DATE,
            SUM(st.quant) ST_Q,
            SUM(ST.Summtax) ST_S,
            st.OPERDATE st_DATE,
            parus.Udo_f_Return_Gy_Regprice_Oei(PIN_GOODSSUPPLY_RN => ST.Goodssupply, PIN_DATE => T.Work_Date) UCHET_PRICE,
            decode(SUM(TS.FACTQUANT), 0, 0, round(SUM(TS.FACTSUMTAX) / SUM(TS.FACTQUANT), 2)) DOC_PRICE
       FROM parus.INORDERS          T,
            parus.doctypes          DT,
            parus.companies         C,
            parus.Inorderspecs      TS,
            parus.nommodif          NM,
            parus.dicnomns          D,
            parus.doclinks          L1,
            parus.SALESREPORTDETAIL SRD1,
            parus.salesreportmain   SR1,
            parus.AZSGSMWAYSTYPES   SKO1,
            parus.doclinks          L2,
            parus.STOREOPERJOURN    ST
      WHERE T.INDOCDATE BETWEEN PIN_D1 AND PIN_D2
        AND T.inDoctype = DT.rn
        AND C.rn = T.Company
        AND (PIN_SCOM IS NULL OR parus.Udo_f_Strinlike(C.Name, S_COMPANY, sDELIMITER, sBLANK, sNotSymb) = 1)
        AND T.rn = TS.Prn
        AND NM.rn = TS.NOMMODIF
        AND NM.prn = D.rn
        AND (pin_DRUG = 0 OR parus.udo_pkg_REP.NOMEN_IS_DRUG(T.Company, NM.prn) = 1) --- Только "таблетка"
        AND (PIN_TMC IS NULL OR parus.Udo_f_Strinlike(D.Nomen_code, S_TMC, sDELIMITER, sBLANK, sNotSymb) = 1)
        AND L1.In_Document = ts.rn
        AND L1.Out_Unitcode = 'TradeReportsSp'
        AND L1.In_Company = T.Company
        AND L1.IN_COMPANY = L1.Out_Company
        AND L1.IN_UNITCODE = 'IncomingOrdersSpecs'
        AND L1.Out_Document = SRD1.rn
        AND SR1.rn = SRD1.prn
        AND SKO1.rn = SRD1.Oper_Code
        AND SKO1.GSMWAYS_TYPE = 1 /* Тип складской операции (0 - расход, 1 - приход) */
        AND L2.In_Document = ts.rn
        AND L2.OUT_UNITCODE = 'StoreOpersJournal'
        AND L2.In_Company = T.Company
        AND L2.IN_COMPANY = L2.Out_Company
        AND L2.In_Unitcode = L1.IN_Unitcode
        AND L2.Out_Document = st.rn
     
      GROUP BY T.Company,
               C.name,
               NM.Modif_Code,
               TS.NOMMODIF,
               TS.NOMNMODIFPACK,
               DT.Doccode,
               TRIM(T.INDOCPREF),
               TRIM(T.INDOCNUMB),
               T.INDOCDATE,
               SR1.RPT_PREFIX,
               sr1.rpt_number,
               sr1.rpt_date,
               st.OPERDATE,
               T.rn,
               SRD1.rn,
               parus.Udo_f_Return_Gy_Regprice_Oei(PIN_GOODSSUPPLY_RN => ST.Goodssupply, PIN_DATE => T.Work_Date)
     
     HAVING SUM(SRD1.PRSUMM_CUR) != SUM(TS.FACTSUMTAX) OR SUM(TS.FACTSUMTAX) != SUM(ST.Summtax) OR SUM(st.quant) != SUM(TS.FACTQUANT) OR round(parus.Udo_f_Return_Gy_Regprice_Oei(PIN_GOODSSUPPLY_RN => ST.Goodssupply, PIN_DATE => T.Work_Date), 2) - decode(SUM(TS.FACTQUANT), 0, 0, round(SUM(TS.FACTSUMTAX) / SUM(TS.FACTQUANT), 2)) > 2);
  --- Расходные накдадные на отпуск потребителям 

  INSERT INTO PARUS.DRUG_TAB_SOOTV_Q_AND_S t
    (SELECT USER SAUTHID,
            V_SES SESID,
            '02 Расходные накладные на отпуск потребителям' VID,
            T.Company,
            C.name,
            NM.Modif_Code,
            TS.NOMMODIF,
            TS.NOMNMODIFPACK,
            SUM(TS.QUANT) N_Q,
            SUM(TS.SUMMWITHNDS) N_S,
            SUM(SRD1.QUANTITY_MAIN) TR_Q,
            SUM(SRD1.PRSUMM_CUR) TR_S,
            DT.Doccode N_TYPE,
            TRIM(T.PREF) N_PRF,
            TRIM(T.Numb) N_NUMB,
            T.Docdate N_date,
            T.rn N_RN,
            TRIM(SR1.RPT_PREFIX) TR_PRF,
            TRIM(sr1.rpt_number) TR_NMB,
            SRD1.rn tr_rn,
            sr1.rpt_date TR_DATE,
            SUM(st.quant) ST_Q,
            SUM(ST.Summtax) ST_S,
            st.OPERDATE st_DATE,
            parus.Udo_f_Return_Gy_Regprice_Oei(PIN_GOODSSUPPLY_RN => ST.Goodssupply, PIN_DATE => T.Work_Date) UCHET_PRICE,
            decode(SUM(TS.QUANT), 0, 0, round(SUM(TS.SUMMWITHNDS) / SUM(TS.QUANT), 2)) DOC_PRICE
       FROM parus.Transinvcust      T,
            parus.doctypes          DT,
            parus.companies         C,
            parus.Transinvcustspecs TS,
            parus.nommodif          NM,
            parus.Dicnomns          D,
            parus.doclinks          L1,
            parus.SALESREPORTDETAIL SRD1,
            parus.salesreportmain   SR1,
            parus.AZSGSMWAYSTYPES   SKO1,
            parus.doclinks          L2,
            parus.STOREOPERJOURN    ST
      WHERE T.Docdate BETWEEN PIN_D1 AND PIN_d2
        AND T.Doctype = DT.rn
        AND C.rn = T.Company
        AND (PIN_SCOM IS NULL OR parus.Udo_f_Strinlike(C.Name, S_COMPANY, sDELIMITER, sBLANK, sNotSymb) = 1)
        AND T.rn = TS.Prn
        AND NM.rn = TS.NOMMODIF
        AND D.rn = nm.prn
        AND (pin_DRUG = 0 OR parus.udo_pkg_REP.NOMEN_IS_DRUG(T.Company, NM.prn) = 1) --- Только "таблетка"
        AND (PIN_TMC IS NULL OR parus.Udo_f_Strinlike(D.Nomen_code, S_TMC, sDELIMITER, sBLANK, sNotSymb) = 1)
        AND L1.In_Document = ts.rn
        AND L1.Out_Unitcode = 'TradeReportsSp'
        AND L1.In_Company = T.Company
        AND L1.IN_COMPANY = L1.Out_Company
        AND L1.IN_UNITCODE = 'GoodsTransInvoicesToConsumersSpecs'
        AND L1.Out_Document = SRD1.rn
        AND SR1.rn = SRD1.prn
        AND SKO1.rn = SRD1.Oper_Code
        AND SKO1.GSMWAYS_TYPE = 0 /* Тип складской операции (0 - расход, 1 - приход) */
        AND L2.In_Document = ts.rn
        AND L2.OUT_UNITCODE = 'StoreOpersJournal'
        AND L2.In_Company = T.Company
        AND L2.IN_COMPANY = L2.Out_Company
        AND L2.In_Unitcode = L1.IN_Unitcode
        AND L2.Out_Document = st.rn
      GROUP BY T.Company,
               C.name,
               NM.Modif_Code,
               TS.NOMMODIF,
               TS.NOMNMODIFPACK,
               DT.Doccode,
               TRIM(T.PREF),
               TRIM(T.Numb),
               T.Docdate,
               SR1.RPT_PREFIX,
               sr1.rpt_number,
               sr1.rpt_date,
               st.OPERDATE,
               T.rn,
               SRD1.rn,
               parus.Udo_f_Return_Gy_Regprice_Oei(PIN_GOODSSUPPLY_RN => ST.Goodssupply, PIN_DATE => T.Work_Date)
     
     HAVING SUM(SRD1.PRSUMM_CUR) != SUM(TS.Summwithnds) OR SUM(TS.Summwithnds) != SUM(ST.Summtax) OR SUM(st.quant) != SUM(TS.QUANT) OR round(parus.Udo_f_Return_Gy_Regprice_Oei(PIN_GOODSSUPPLY_RN => ST.Goodssupply, PIN_DATE => T.Work_Date), 2) - decode(SUM(TS.QUANT), 0, 0, round(SUM(TS.SUMMWITHNDS) / SUM(TS.QUANT), 2)) > 2);

  --- Расходные накдадные на отпуск в подразделения

  INSERT INTO PARUS.DRUG_TAB_SOOTV_Q_AND_S t
    (SELECT USER SAUTHID,
            V_SES SESID,
            '03 Расходные накладные на отпуск в подразделения' VID,
            T.Company,
            C.name,
            NM.Modif_Code,
            TS.NOMMODIF,
            TS.NOMNMODIFPACK,
            SUM(TS.QUANT) N_Q,
            SUM(TS.SUMMWITHNDS) N_S,
            SUM(SRD1.QUANTITY_MAIN) TR_Q,
            SUM(SRD1.PRSUMM_CUR) TR_S,
            DT.Doccode N_TYPE,
            TRIM(T.PREF) N_PRF,
            TRIM(T.Numb) N_NUMB,
            T.Docdate N_date,
            T.rn N_RN,
            TRIM(SR1.RPT_PREFIX) TR_PRF,
            TRIM(sr1.rpt_number) TR_NMB,
            SRD1.rn tr_rn,
            sr1.rpt_date TR_DATE,
            SUM(st.quant) ST_Q,
            SUM(ST.Summtax) ST_S,
            st.OPERDATE st_DATE,
            parus.Udo_f_Return_Gy_Regprice_Oei(PIN_GOODSSUPPLY_RN => ST.Goodssupply, PIN_DATE => T.Work_Date) UCHET_PRICE,
            decode(SUM(TS.QUANT), 0, 0, round(SUM(TS.SUMMWITHNDS) / SUM(TS.QUANT), 2)) DOC_PRICE
       FROM parus.TRANSINVDEPT      T,
            parus.doctypes          DT,
            parus.companies         C,
            parus.Transinvdeptspecs TS,
            parus.nommodif          NM,
            parus.dicnomns          D,
            parus.doclinks          L1,
            parus.SALESREPORTDETAIL SRD1,
            parus.salesreportmain   SR1,
            parus.AZSGSMWAYSTYPES   SKO1,
            parus.doclinks          L2,
            parus.STOREOPERJOURN    ST
      WHERE T.Docdate BETWEEN PIN_D1 AND PIN_d2
        AND T.Doctype = DT.rn
        AND C.rn = T.Company
        AND (PIN_SCOM IS NULL OR parus.Udo_f_Strinlike(C.Name, S_COMPANY, sDELIMITER, sBLANK, sNotSymb) = 1)
        AND T.rn = TS.Prn
        AND NM.rn = TS.Nommodif
        AND D.rn = NM.prn
        AND (pin_DRUG = 0 OR parus.udo_pkg_REP.NOMEN_IS_DRUG(T.Company, NM.prn) = 1) --- Только "таблетка"
        AND (PIN_TMC IS NULL OR parus.Udo_f_Strinlike(D.Nomen_code, S_TMC, sDELIMITER, sBLANK, sNotSymb) = 1)
        AND L1.In_Document = ts.rn
        AND L1.Out_Unitcode = 'TradeReportsSp'
        AND L1.In_Company = T.Company
        AND L1.IN_COMPANY = L1.Out_Company
        AND L1.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
        AND L1.Out_Document = SRD1.rn
        AND SR1.rn = SRD1.prn
        AND SKO1.rn = SRD1.Oper_Code
        AND SKO1.GSMWAYS_TYPE = 0 /* Тип складской операции (0 - расход, 1 - приход) */
        AND L2.In_Document = ts.rn
        AND L2.OUT_UNITCODE = 'StoreOpersJournal'
        AND L2.In_Company = T.Company
        AND L2.IN_COMPANY = L2.Out_Company
        AND L2.In_Unitcode = L1.IN_Unitcode
        AND L2.Out_Document = st.rn
     
      GROUP BY T.Company,
               C.name,
               NM.Modif_Code,
               TS.NOMMODIF,
               TS.NOMNMODIFPACK,
               DT.Doccode,
               TRIM(T.PREF),
               TRIM(T.Numb),
               T.Docdate,
               T.rn,
               SRD1.rn,
               SR1.RPT_PREFIX,
               sr1.rpt_number,
               sr1.rpt_date,
               st.OPERDATE,
               parus.Udo_f_Return_Gy_Regprice_Oei(PIN_GOODSSUPPLY_RN => ST.Goodssupply, PIN_DATE => T.Work_Date)
     
     HAVING SUM(SRD1.PRSUMM_CUR) != SUM(TS.Summwithnds) OR SUM(TS.Summwithnds) != SUM(ST.Summtax) OR SUM(st.quant) != SUM(TS.QUANT) OR round(parus.Udo_f_Return_Gy_Regprice_Oei(PIN_GOODSSUPPLY_RN => ST.Goodssupply, PIN_DATE => T.Work_Date), 2) - decode(SUM(TS.QUANT), 0, 0, round(SUM(TS.SUMMWITHNDS) / SUM(TS.QUANT), 2)) > 2);

  FOR cur IN (SELECT T.Name,
                     T.VID,
                     t.modif_code mc,
                     t.N_TYPE,
                     T.N_PRF || '-' || T.N_NUMB N_NMB,
                     to_char(T.N_DATE, 'DD.MM.YYYY') N_D,
                     T.N_Q,
                     T.N_S,
                     decode(T.N_Q, 0, 0, T.N_S / T.N_Q) N_P,
                     T.UCHET_PRICE,
                     T.ST_Q,
                     T.ST_S,
                     T.ST_DATE,
                     T.TR_NMB,
                     T.TR_Q,
                     T.TR_S,
                     T.TR_DATE,
                     H.NMB H_NMB,
                     H.S H_S,
                     H.Q H_Q, 
                     H.D H_D
                FROM PARUS.DRUG_TAB_SOOTV_Q_AND_S T,
                     (SELECT srd.rn RN, TRIM(E.OPERATION_PREF) || '-' || TRIM(E.Operation_Numb) NMB, E.Operation_Date D, FHO.Acnt_Sum S, FHO.ACNT_QUANT Q
                        FROM parus.salesreportdetail SRD, parus.doclinks L, parus.OPRSPECS FHO, parus.ECONOPRS E
                       WHERE L.IN_DOCUMENT = srd.rn
                         and L.Out_Unitcode = 'EconomicOperationsSpecs'
                         AND L.Out_Company = L.In_Company
                         and L.in_company = srd.company
                         AND l.in_unitcode = 'TradeReportsSp'
                         AND FHO.rn = L.Out_Document
                         AND FHO.Nomenclature IS NOT NULL
                         AND E.rn = FHO.prn) H
               WHERE T.SAUTHID = USER
                 AND T.SESID = V_SES
                 AND T.tr_RN = H.rn(+)
               ORDER BY T.name, T.vid, t.modif_code) LOOP
    IF CUR.Name != V_ORG THEN
      V_ORG := CUR.Name;
      IF V_FL_org = 0 THEN
        nLineIndex := prsg_excel.LINE_APPEND(LINE_ORG);
      ELSE
        nLineIndex := prsg_excel.LINE_CONTINUE(LINE_ORG);
      END IF;
      prsg_excel.CELL_VALUE_WRITE('ORG_NAME', 0, nLineIndex, V_ORG);
      V_FL_org := 1;
      V_VID    := '#';
    
    END IF;
  
    IF cur.vid != V_VID THEN
      V_VID      := cur.vid;
      nLineIndex := prsg_excel.LINE_CONTINUE(LINE_VID);
      prsg_excel.CELL_VALUE_WRITE('VID_RAZD', 0, nLineIndex, substr(V_VID, 3));
    END IF;
  
    nLineIndex := prsg_excel.LINE_CONTINUE(LINE1);
    prsg_excel.CELL_VALUE_WRITE('CELL1', 0, nLineIndex, nLineIndex);
    prsg_excel.CELL_VALUE_WRITE('CELL2', 0, nLineIndex, cUR.MC);
    prsg_excel.CELL_VALUE_WRITE('CELL3', 0, nLineIndex, cUR.N_TYPE);
    prsg_excel.CELL_VALUE_WRITE('CELL4', 0, nLineIndex, cUR.N_NMB);
    prsg_excel.CELL_VALUE_WRITE('CELL5', 0, nLineIndex, cUR.N_D);
    prsg_excel.CELL_VALUE_WRITE('CELL6', 0, nLineIndex, cUR.N_Q);
    prsg_excel.CELL_VALUE_WRITE('CELL15', 0, nLineIndex, cUR.N_P);
    prsg_excel.CELL_VALUE_WRITE('CELL7', 0, nLineIndex, cUR.N_S);
    prsg_excel.CELL_VALUE_WRITE('CELL16', 0, nLineIndex, cUR.UCHET_PRICE);
    prsg_excel.CELL_VALUE_WRITE('CELL8', 0, nLineIndex, cUR.ST_Q);
    prsg_excel.CELL_VALUE_WRITE('CELL9', 0, nLineIndex, cUR.ST_S);
    prsg_excel.CELL_VALUE_WRITE('CELL10', 0, nLineIndex, cUR.ST_DATE);
    prsg_excel.CELL_VALUE_WRITE('CELL11', 0, nLineIndex, cUR.TR_NMB);
    prsg_excel.CELL_VALUE_WRITE('CELL12', 0, nLineIndex, cUR.TR_Q);
    prsg_excel.CELL_VALUE_WRITE('CELL13', 0, nLineIndex, cUR.TR_S);
    prsg_excel.CELL_VALUE_WRITE('CELL14', 0, nLineIndex, cUR.TR_DATE);
    prsg_excel.CELL_VALUE_WRITE('CELL17', 0, nLineIndex, cUR.H_NMB);
    prsg_excel.CELL_VALUE_WRITE('CELL18', 0, nLineIndex, cUR.H_Q);
    prsg_excel.CELL_VALUE_WRITE('CELL19', 0, nLineIndex, cUR.H_S);
    prsg_excel.CELL_VALUE_WRITE('CELL20', 0, nLineIndex, cUR.H_D);
  END LOOP;

  prsg_excel.LINE_DELETE(LINE1);
  prsg_excel.LINE_DELETE(LINE_ORG);
  prsg_excel.LINE_DELETE(LINE_VID);
  prsg_excel.LINE_DELETE(LINE_D1);
  prsg_excel.LINE_DELETE(LINE_D2);

  IF PIN_TMC IS NULL OR pin_TMC = '*' THEN
    prsg_excel.LINE_DELETE(LINE_TMC);
  ELSE
    parus.prsg_excel.CELL_VALUE_WRITE('PO_TMC', PIN_TMC);
  
  END IF;

END;
/
