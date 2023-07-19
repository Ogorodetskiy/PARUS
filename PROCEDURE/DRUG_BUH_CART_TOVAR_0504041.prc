CREATE OR REPLACE PROCEDURE PARUS.DRUG_BUH_CART_TOVAR_0504041(PIN_IDENT IN NUMBER, PIN_COM IN NUMBER, PIN_OTDEL IN VARCHAR2, pin_AGENT IN VARCHAR2, PIN_D DATE) IS

  -- рабочий лист
  SF CONSTANT PKG_STD.TSTRING := 'KT';
  SCUR_SHEET_NAME PKG_STD.TSTRING;

  CELL_ORGNAME    CONSTANT PKG_STD.TSTRING := 'ORGNAME';
  CELL_OTDEL      CONSTANT PKG_STD.TSTRING := 'OTDEL';
  CELL_MOL        CONSTANT PKG_STD.TSTRING := '_MOL';
  CELL_S4ET       CONSTANT PKG_STD.TSTRING := 'S4ET';
  CELL_MATNAME    CONSTANT PKG_STD.TSTRING := 'MATNAME';
  CELL_NOMEN_CODE CONSTANT PKG_STD.TSTRING := 'NOMEN_CODE';
  CELL_OKPO       CONSTANT PKG_STD.TSTRING := 'OKPO';
  CELL_NOMER      CONSTANT PKG_STD.TSTRING := 'NOMER';
  CELL_DOL1       CONSTANT PKG_STD.TSTRING := '_DOL1';
  CELL_FIO1       CONSTANT PKG_STD.TSTRING := '_FIO1';
  CELL_DAY1       CONSTANT PKG_STD.TSTRING := '_DAY1';
  CELL_MES1       CONSTANT PKG_STD.TSTRING := '_MES1';
  CELL_YEAR1      CONSTANT PKG_STD.TSTRING := 'YEAR1';

  LINE CONSTANT PKG_STD.TSTRING := 'LINE';

  V_FIO VARCHAR2(240);
  V_DOL VARCHAR2(240);

  OST_S parus.valturns.acnt_res_sum%TYPE;
  OST_Q parus.valturns.ACNT_RES_QUANT%TYPE;

  V_OTD_NAME Parus.Ins_Department.name%TYPE;

  i     INTEGER;
  IDX   INTEGER;
  V_IDN parus.selectlist.ident%TYPE;

BEGIN
  /* пролог */
  PRSG_EXCEL.PREPARE;
  SCUR_SHEET_NAME := PRSG_EXCEL.FORM_SHEET_NAME(SF);
  PRSG_EXCEL.SHEET_SELECT(SCUR_SHEET_NAME);

  PRSG_EXCEL.CELL_DESCRIBE(CELL_ORGNAME);

  PRSG_EXCEL.CELL_DESCRIBE(CELL_MOL);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_S4ET);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_MATNAME);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_OKPO);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_NOMER);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_DOL1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_FIO1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_DAY1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_MES1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_YEAR1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_NOMEN_CODE);

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_DAY1, to_char(nvl(PIN_D, SYSDATE), 'DD'));
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_MES1, parus.udo_PKG_REP.Month_NAME(nvl(PIN_D, SYSDATE), 1));
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_YEAR1, to_char(nvl(PIN_D, SYSDATE), 'YY'));

  parus.Udo_Pkg_Rep.AGENT_ATTR(PIN_COM => pin_COM, PIN_REJ => 1, PIN_SAGN => pin_AGENT, OUT_FIO => V_FIO, OUT_DOL => V_DOL);

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_DOL1, V_DOL);
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_FIO1, V_FIO);

  PRSG_EXCEL.LINE_DESCRIBE(LINE);

  FOR i IN 1 .. 13 LOOP
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE, 'COL' || to_char(i));
  END LOOP;

  IF PIN_OTDEL IS NOT NULL THEN
    PRSG_EXCEL.CELL_DESCRIBE(CELL_OTDEL);
  
    BEGIN
      SELECT D.NAME
        INTO V_OTD_NAME
        FROM parus.ins_department D
       WHERE D.CODE = PIN_OTDEL
         AND D.Company = PIN_COM;
    EXCEPTION
      WHEN no_data_found THEN
        V_OTD_NAME := PIN_OTDEL;
    END;
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_OTDEL, V_OTD_NAME);
  
  END IF;

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_ORGNAME, parus.udo_PKG_REP.COMPANY_AGNLIST_NAME(PIN_COM => PIN_COM, PIN_REJ => 1));
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_OKPO, parus.udo_PKG_REP.COMPANY_AGNLIST_OKPO(PIN_COM => PIN_COM, PIN_REJ => 1));

  FOR cur IN (SELECT T.rn, T.Company, T.agent, MOL.agnabbr MOL, S4.ACC_NUMBER, s4.ACC_NAME, D.nomen_name, D.nomen_code, OEI.MEAS_MNEMO EI, D.rn NOM_RN, S4.rn S4_RN, T.ACNT_RES_QUANT Q_END, T.ACNT_RES_SUM S_END
                FROM parus.selectlist L, parus.VALTURNS T, parus.agnlist MOL, parus.DICACCS S4, parus.dicnomns D, parus.dicmunts OEI
               WHERE L.IDENT = PIN_IDENT
                 AND L.AUTHID = USER
                 AND L.Company = PIN_COM
                 AND T.RN = L.DOCUMENT
                 AND MOL.rn = T.agent
                 AND T.ACCOUNT = S4.rn(+)
                 AND T.NOMENCLATURE = D.rn
                 AND D.UMEAS_MAIN = OEI.rn) LOOP
  
    -- установка рабочего листа
    SCUR_SHEET_NAME := PRSG_EXCEL.FORM_SHEET_NAME(SF || cur.rn);
    PRSG_EXCEL.SHEET_COPY(SF, SCUR_SHEET_NAME);
  
    PRSG_EXCEL.SHEET_SELECT(SCUR_SHEET_NAME);
  
    parus.Udo_Pkg_Rep.AGENT_ATTR(PIN_COM => pin_COM, PIN_REJ => 1, PIN_SAGN => cur.MOL, OUT_FIO => V_FIO);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_MOL, nvl(V_FIO, cur.MOL));
  
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_S4ET, cur.acc_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_Nomer, cur.acc_number);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_MATNAME, cur.Nomen_Name);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_NOMEN_CODE, cur.nomen_code);
  
    --- по хоз операциям
    P_SELECTLIST_GENIDENT(V_IDN);
    parus.P_VALTURNS_ECOPER_SELECT(cur.rn, V_IDN, 0);
  
    OST_S := cur.s_end;
    OST_Q := cur.q_End;
  
    FOR H IN (SELECT TRIM(HO.OPERATION_NUMB) NMB, HO.OPERATION_DATE D, HO.OPERATION_CONTENTS NM, HS.Account_Debit DB, HS.Account_credit CR, HS.ACNT_SUM S, HS.ACNT_QUANT Q, HO.AGENT_FROM OTKOGO, HO.agent_TO KOMU
                FROM parus.selectlist L, parus.Econoprs HO, parus.OPRSPECS HS
               WHERE L.IDENT = V_IDN
                 AND L.authid = USER
                 AND L.UNITCODE = 'EconomicOperations'
                 AND HO.RN = L.DOCUMENT
                 AND HS.prn = HO.rn
                 AND HS.NOMENCLATURE = cur.NOM_RN
                 AND cur.S4_RN IN (HS.Account_Debit, hs.account_credit)
               ORDER BY HO.OPERATION_DATE DESC,
                        CASE hs.account_credit
                          WHEN cur.S4_RN THEN
                           0
                          ELSE
                           1
                        END,
                        HO.OPERATION_NUMB -- Сортируем сначала расход, потом приход
              ) LOOP
    
      IDX := PRSG_EXCEL.LINE_APPEND(LINE);
      PRSG_EXCEL.CELL_VALUE_WRITE('_COL1', 0, IDX, to_char(H.D, 'DD.MM.YYYY'));
      PRSG_EXCEL.CELL_VALUE_WRITE('_COL2', 0, IDX, H.NMB);
      PRSG_EXCEL.CELL_VALUE_WRITE('_COL3', 0, IDX, H.NM);
      PRSG_EXCEL.CELL_VALUE_WRITE('_COL7', 0, IDX, cur.EI); --- Ед. Изм.
      PRSG_EXCEL.CELL_VALUE_WRITE('_COL6', 0, IDX, CASE H.Q WHEN 0 THEN 0 ELSE round(H.S / H.Q, 2) END); --- Цена
    
      PRSG_EXCEL.CELL_VALUE_WRITE('_COL12', 0, IDX, OST_Q); --- Ост. Кол-во.
      PRSG_EXCEL.CELL_VALUE_WRITE('_COL13', 0, IDX, OST_S); --- Ост. Сумма.
    
      IF cur.s4_rn = H.DB AND H.db = H.CR THEN
        --- Внутреннее перемещение
        IF H.OTKOGO = H.komu THEN
          --- внутри одного МОЛ
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL8', 0, IDX, H.Q); --- Дб. Кол-во.
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL9', 0, IDX, H.S); --- Дб. Сумма.
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL10', 0, IDX, H.Q); --- Кр. Кол-во.
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL11', 0, IDX, H.S); --- Кр. Сумма.
        ELSIF H.OTKOGO = cur.AGENT THEN
          -- расход 
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL10', 0, IDX, H.Q); --- Кр. Кол-во.
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL11', 0, IDX, H.S); --- Кр. Сумма.
          OST_S := OST_S + H.S;
          OST_Q := OST_Q + H.Q;
        ELSE --приход
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL8', 0, IDX, H.Q); --- Дб. Кол-во.
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL9', 0, IDX, H.S); --- Дб. Сумма.
          OST_S := OST_S - H.S;
          OST_Q := OST_Q - H.Q;
        END IF;
      
      ELSE
        IF cur.s4_rn = H.DB THEN
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL8', 0, IDX, H.Q); --- Дб. Кол-во.
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL9', 0, IDX, H.S); --- Дб. Сумма.
          OST_S := OST_S - H.S;
          OST_Q := OST_Q - H.Q;
        ELSE
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL10', 0, IDX, H.Q); --- Кр. Кол-во.
          PRSG_EXCEL.CELL_VALUE_WRITE('_COL11', 0, IDX, H.S); --- Кр. Сумма.
          OST_S := OST_S + H.S;
          OST_Q := OST_Q + H.Q;
        END IF;
      END IF;
    
    END LOOP;
    PRSG_EXCEL.LINE_DELETE(LINE);
  END LOOP;

  PRSG_EXCEL.SHEET_DELETE(SF);

END;
/
