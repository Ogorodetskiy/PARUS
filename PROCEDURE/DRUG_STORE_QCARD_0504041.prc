CREATE OR REPLACE PROCEDURE PARUS.DRUG_STORE_QCARD_0504041(PIN_COM        IN NUMBER,
                                                           PIN_OTDEL      IN VARCHAR2,
                                                           PIN_STORE      IN VARCHAR2,
                                                           pin_MOL        IN VARCHAR2,
                                                           PIN_NOMEN      IN VARCHAR2,
                                                           PIN_D1         DATE,
                                                           PIN_D2         DATE,
                                                           PIN_ZAPOLN_FIO IN VARCHAR2,
                                                           PIN_ZAPOLN_DOL IN VARCHAR2) IS

  /* карточка товара для склада по бухгалтерской форме */

  -- рабочий лист
  SH CONSTANT PKG_STD.tSTRING := 'KT';
  IND INTEGER := 0;

  CELL_ORGNAME    CONSTANT PKG_STD.TSTRING := 'ORGNAME';
  CELL_OTDEL      CONSTANT PKG_STD.TSTRING := 'OTDEL';
  CELL_MOL        CONSTANT PKG_STD.TSTRING := 'MOL_1';
  CELL_S4ET       CONSTANT PKG_STD.TSTRING := 'S4ET';
  CELL_NOMEN_NAME CONSTANT PKG_STD.TSTRING := 'MATNAME';
  CELL_NOMEN_CODE CONSTANT PKG_STD.TSTRING := 'NOMEN_CODE';
  CELL_OKPO       CONSTANT PKG_STD.TSTRING := 'OKPO';
  CELL_NOMER      CONSTANT PKG_STD.TSTRING := 'NOMER';
  CELL_DOL1       CONSTANT PKG_STD.TSTRING := 'DOL_1';
  CELL_FIO1       CONSTANT PKG_STD.TSTRING := 'FIO_1';
  CELL_DAY1       CONSTANT PKG_STD.TSTRING := 'DAY_1';
  CELL_MES1       CONSTANT PKG_STD.TSTRING := 'MES_1';
  CELL_YEAR1      CONSTANT PKG_STD.TSTRING := 'YEAR1';

  CELL_D1    CONSTANT PKG_STD.TSTRING := 'CELL_D1';
  CELL_OST_Q CONSTANT PKG_STD.TSTRING := 'CELL_OST_Q';
  CELL_EI    CONSTANT PKG_STD.TSTRING := 'CELL_EI';
  CELL_OST_S CONSTANT PKG_STD.TSTRING := 'CELL_OST_S';

  LINE CONSTANT PKG_STD.TSTRING := 'LINE';

  V_FIO VARCHAR2(240);
  V_DOL VARCHAR2(240);

  OST_S parus.valturns.acnt_res_sum%TYPE;
  OST_Q parus.valturns.ACNT_RES_QUANT%TYPE;

  V_OPER_NUMB VARCHAR2(255);
  V_FHO_SP_RN OPRSPECS.rn%TYPE;
  V_FHO_TXT   ECONOPRS.OPERATION_CONTENTS%TYPE;
  V_FHO_DATE  ECONOPRS.OPERATION_DATE%TYPE;

  V_OTD_NAME Parus.Ins_Department.name%TYPE;

  i     INTEGER := 0;
  IDX   INTEGER;
  V_IDN parus.selectlist.ident%TYPE;

  CUR_FHO SYS_REFCURSOR;

  TYPE TYP_REC_FHO IS RECORD(
    DB        VARCHAR2(40), -- Счет Дб
    DBA1      VARCHAR2(40), -- Аналит. Дб. первого уровня
    DBA2      VARCHAR2(40), -- Аналит. Дб. вторго уровня
    DBA3      VARCHAR2(40), -- Аналит. Дб. третьего уровня
    DBA4      VARCHAR2(40), -- Аналит. Дб. четвертого уровня  
    DBA5      VARCHAR2(40), -- Аналит. Дб. пятого уровня 
    KR        VARCHAR2(40), -- Счет Кр
    KRA1      VARCHAR2(40), -- Аналит. Кр. первого уровня
    KRA2      VARCHAR2(40), -- Аналит. Кр. вторго уровня
    KRA3      VARCHAR2(40), -- Аналит. Кр. третьего уровня
    KRA4      VARCHAR2(40), -- Аналит. Кр. четвертого уровня  
    KRA5      VARCHAR2(40), -- Аналит. Кр. пятого уровня
    PBE_DB    VARCHAR2(20), -- ПБЕ Дб 
    PBE_KR    VARCHAR2(20), -- ПБЕ Кр
    S         NUMBER(17, 2), -- Cумма
    Q         NUMBER(17, 3), -- Количество
    NOMEN_RN  NUMBER(17), ---RN Номенклатуры
    FHO_SP_RN NUMBER(17) --- RN  Спецификации проводки
    );

  V_REC_FHO TYP_REC_FHO;

BEGIN

  IF PIN_OTDEL IS NULL AND pin_MOL IS NULL AND PIN_STORE IS NULL THEN
    P_exception(0
               ,'Обязательно должно быть заполнено хотя бы одно из значений параметров:
    Отделение, МОЛ, Склад');
  
  END IF;

  --- Формируем данные*/

  INSERT INTO DRUG_TAB_QCARD_0504041
  
    (
     
    SELECT 
       Lt.Out_Document Tr_Sp_Rn,
       d.Rn Nomen_Rn,
       d.Nomen_Code,
       d.Nomen_Name,
       Ei.Meas_Mnemo Oei,
       St.Oper_Type Napr_Rash,
       St.Quant,
       St.Summtax,
       Gy.Rn Gyrn,
       Skl.Azs_Number,
       Dep.Code Dep_Code,
       Dep.Name Dep_Name,
       Mol.Agnabbr Mol,
       Udo_Pkg_Rep.Storeoperjourn_Mol(St.Rn, St.Unitcode, 'CODE_TO') Skl_To,
       St.Operdate,
       Nm.Rn
  FROM Storeoperjourn St
  JOIN Goodssupply Gy
    ON Gy.Rn = St.Goodssupply
  JOIN Azsazslistmt Skl
    ON Skl.Rn = Gy.Store
   AND (PIN_STORE IS NULL OR Skl.Azs_Number = PIN_STORE)
  LEFT JOIN Ins_Department Dep
    ON Dep.Rn = Skl.Department AND (PIN_OTDEL IS NULL OR dep.code = PIN_OTDEL)
  LEFT JOIN Agnlist Mol
    ON Mol.Rn = Skl.Azs_Agent  AND (pin_MOL IS NULL OR mol.agnabbr = PIN_MOL)
  JOIN Goodsparties Gp
    ON Gp.Rn = Gy.Prn
  JOIN Nommodif Nm
    ON Gp.Nommodif = Nm.Rn
  JOIN Dicnomns d
    ON d.Rn = Nm.Prn
   AND d.Nomen_Code = PIN_NOMEN
  JOIN Dicmunts Ei
    ON Ei.Rn = d.Umeas_Main
  JOIN Doclinks Ld
    ON Ld.Out_Document = St.Rn
   AND Ld.In_Unitcode = (CASE St.Unitcode
         WHEN 'GoodsTransInvoicesToConsumers' THEN
          'GoodsTransInvoicesToConsumersSpecs'
         WHEN 'GoodsTransInvoicesToDepts' THEN
          'GoodsTransInvoicesToDeptsSpecs'
         WHEN 'IncomingOrders' THEN
          'IncomingOrdersSpecs'
         WHEN 'ReturnInvoicesToSuppliers' THEN
          'ReturnInvoicesToSuppliersSpecs'
         ELSE
          NULL
       END)
   AND Ld.Out_Unitcode = 'StoreOpersJournal'
   AND Ld.In_Company = St.Company
   AND Ld.Out_Company = Ld.In_Company
  LEFT JOIN Doclinks Lt
    ON Lt.In_Document = Ld.In_Document
   AND Lt.Out_Unitcode = 'TradeReportsSp'
 WHERE St.Company = PIN_COM
   AND St.Unitcode IN ('GoodsTransInvoicesToConsumers'
                      ,'GoodsTransInvoicesToDepts'
                      ,'IncomingOrders'
                      ,'ReturnInvoicesToSuppliers')
   AND St.Operdate BETWEEN PIN_D1 AND PIN_D2
   AND St.Signplan != 1
     
     );

  P_exception(SQL%ROWCOUNT
             ,'По указанным условиям отбора записей в журнале складских операций не найдено, формирование отчета невозможно');

  /* пролог */
  PRSG_EXCEL.PREPARE;

  PRSG_EXCEL.SHEET_SELECT(SH);

  PRSG_EXCEL.CELL_DESCRIBE(CELL_ORGNAME);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_MOL);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_OKPO);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_OTDEL);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_NOMEN_CODE);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_NOMEN_NAME);

  PRSG_EXCEL.CELL_DESCRIBE(CELL_NOMER);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_DOL1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_FIO1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_DAY1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_MES1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_YEAR1);

  PRSG_EXCEL.CELL_DESCRIBE(CELL_D1);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_OST_Q);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_EI);
  PRSG_EXCEL.CELL_DESCRIBE(CELL_OST_S);

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_DOL1, V_DOL);
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_FIO1, V_FIO);

  PRSG_EXCEL.LINE_DESCRIBE(LINE);

  FOR i IN 1 .. 13 LOOP
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE, 'COL_' || to_char(i));
  END LOOP;

  --- Выводим постоянный заголовок

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_ORGNAME, parus.udo_PKG_REP.COMPANY_AGNLIST_NAME(PIN_COM => PIN_COM, PIN_REJ => 1));
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_OKPO, parus.udo_PKG_REP.COMPANY_AGNLIST_OKPO(PIN_COM => PIN_COM, PIN_REJ => 1));

  --- Выводим постоянный подвал 

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_DAY1, to_char(SYSDATE, 'DD'));
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_MES1, parus.udo_PKG_REP.Month_NAME(SYSDATE, 1));
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_YEAR1, to_char(SYSDATE, 'YY'));

  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_FIO1, PIN_ZAPOLN_FIO);
  PRSG_EXCEL.CELL_VALUE_WRITE(CELL_DOL1, PIN_ZAPOLN_DOL);

  --- Отдельная карточка по каждому МОЛ, Отделу, Складу , Номенклатуре

  FOR ZAG IN (SELECT DISTINCT 
               T.MOL_FROM, 
               T.DEP_CODE, 
               T.NOMEN_CODE, 
               T.NOMEN_NAME, 
               T.OEI ,
               T.MODIF_RN
               FROM DRUG_TAB_QCARD_0504041 T)
  
   LOOP
  
    I := I + 1;
    PRSG_EXCEL.SHEET_COPY(SH, SH || '_' || I);
    PRSG_EXCEL.SHEET_SELECT(SH || '_' || I);
  
    --- Выводим шапку документа
  
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_MOL, ZAG.MOL_FROM);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_OTDEL, ZAG.DEP_CODE);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_NOMEN_CODE, ZAG.nomen_code);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_NOMEN_NAME, ZAG.nomen_NAME);
  
    --- Выводим остаток на дату
  
    OST_S := 0;
    OST_Q := 0;
  
FOR ost IN (SELECT distinct T.AZS_NUMBER_FROM STORE
                  FROM DRUG_TAB_QCARD_0504041 T
                 WHERE T.MOL_FROM = zag.mol_from
                       AND T.NOMEN_CODE = zag.nomen_code
                       AND T.OEI = ZAG.OEI
                       AND nvl(T.DEP_CODE, '###') = nvl(zag.dep_code, '###')
                       ) LOOP
                
    
    
    OST_S := OST_S +udo_PKG_REP.OST_NOMMODIF(PIN_COM, ZAG.MODIF_RN,PIN_D1,ost.STORE , 'S'); 
    OST_Q := OST_Q +udo_PKG_REP.OST_NOMMODIF(PIN_COM, ZAG.MODIF_RN,PIN_D1,ost.STORE , 'Q');
    
    end loop;
    
---    END LOOP;
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_D1, to_CHAR(PIN_D1, 'DD.MM.YYYY'));
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_OST_Q, OST_Q);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_EI, ZAG.OEI);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_OST_S, OST_S);
  
    --- Выводим СПЕЦИФИКАЦИЮ
  
    FOR SPE IN (SELECT T.OPER_DATE, T.TR_SP_RN, T.NAPR_RASH, T.OEI,  T.SUMTAX S, T.QUANT Q
                  FROM DRUG_TAB_QCARD_0504041 T
                 WHERE T.MOL_FROM = zag.mol_from
                       AND T.NOMEN_CODE = zag.nomen_code
                       AND T.OEI = ZAG.OEI
                       AND nvl(T.DEP_CODE, '###') = nvl(zag.dep_code, '###')
                
                 ORDER BY 1) LOOP
    
      BEGIN
        SELECT TRIM(E.Operation_Pref) || '-' || TRIM(E.Operation_Numb),
        SP.rn, E.OPERATION_CONTENTS, E.OPERATION_DATE
          INTO V_OPER_NUMB, V_FHO_SP_RN, V_FHO_TXT , V_FHO_DATE 
          FROM doclinks L, OPRSPECS SP, ECONOPRS E
         WHERE L.IN_DOCUMENT = SPE.TR_SP_RN
               AND L.Out_Unitcode = 'EconomicOperationsSpecs'
               AND L.OUT_COMPANY = PIN_COM
               AND L.In_Company = L.Out_Company
               AND L.In_Unitcode = 'TradeReportsSp'
               AND L.out_document = SP.rn
               AND E.rn = SP.prn;
      EXCEPTION
        WHEN no_data_found THEN
          V_OPER_NUMB := NULL;
          V_FHO_SP_RN :=null;
      END;
    
    IDX := PRSG_EXCEL.LINE_APPEND(LINE);
    if V_FHO_SP_RN is not null then
    
      --- На само деле нам проводки Дб/Кр не нужны, можно упростить вывод только номером проводки и 
    
      
      PRSG_EXCEL.CELL_VALUE_WRITE('COL_3', 0, IDX, V_FHO_SP_RN);
    
      CUR_FHO := UDO_PKG_REP.ACCOUNTING_ENTRY(V_FHO_SP_RN, 0, 'TradeReportsSp');
    
      LOOP
        FETCH CUR_FHO
          INTO V_REC_FHO;
        EXIT WHEN CUR_FHO%NOTFOUND;
        IF substr(V_REC_FHO.DB, 19, 3) != '502' AND V_REC_FHO.NOMEN_RN IS NOT NULL THEN
        
          PRSG_EXCEL.CELL_VALUE_WRITE('COL_1', 0, IDX, to_char(SPE.Oper_Date, 'DD.MM.YYYY'));
          PRSG_EXCEL.CELL_VALUE_WRITE('COL_2', 0, IDX, V_OPER_NUMB);
          PRSG_EXCEL.CELL_VALUE_WRITE('COL_3', 0, IDX, V_FHO_TXT||' от '||to_char(V_FHO_DATE,'DD.MM.YYYY'));
          PRSG_EXCEL.CELL_VALUE_WRITE('COL_6', 0, IDX, CASE V_REC_FHO.Q WHEN 0 THEN 0 ELSE round(V_REC_FHO.S / V_REC_FHO.Q, 2) END); --- Цена
          PRSG_EXCEL.CELL_VALUE_WRITE('COL_7', 0, IDX, SPE.OEI); --- Ед. Изм.  
        
        END IF;
        
         END LOOP; --- Конец проводки   
         
         
         else -- Товарный отчет не сформирован!
           
         PRSG_EXCEL.CELL_VALUE_WRITE('COL_1', 0, IDX, to_char(SPE.Oper_Date, 'DD.MM.YYYY'));
         PRSG_EXCEL.CELL_VALUE_WRITE('COL_2', 0, IDX, 'Не сформирована');
         
      end if;   
         
        if spe.napr_rash = 1 then --- Приход
          PRSG_EXCEL.CELL_VALUE_WRITE('COL_8', 0, IDX, SPE.Q); 
          PRSG_EXCEL.CELL_VALUE_WRITE('COL_9', 0, IDX, SPE.S); 
        
        else  --- Расход
          PRSG_EXCEL.CELL_VALUE_WRITE('COL_10', 0, IDX, SPE.Q); 
          PRSG_EXCEL.CELL_VALUE_WRITE('COL_11', 0, IDX, SPE.S);
        
        end if;
        
        OST_S :=OST_S + (2*spe.napr_rash-1)*spe.s;
        OST_Q := OST_Q  +(2*spe.napr_rash-1)*spe.Q;
        
        PRSG_EXCEL.CELL_VALUE_WRITE('COL_12', 0, IDX, OST_Q); 
        PRSG_EXCEL.CELL_VALUE_WRITE('COL_13', 0, IDX, OST_S);
        
        
        
        
               
    
    END LOOP; --- Конец спецификации
    
    
  
    IF IDX IS NOT NULL THEN
      PRSG_EXCEL.LINE_DELETE(LINE);
      IDX := NULL;
    
    END IF;
  
  --- P_EXCEPTION(0,'!' );
  
  END LOOP;

  
  IF i > 0 THEN
    PRSG_EXCEL.SHEET_DELETE(SH);
  ELSE
    NULL; --- 'По заданным парметрам данных не найдено');
  END IF;
END;
/
