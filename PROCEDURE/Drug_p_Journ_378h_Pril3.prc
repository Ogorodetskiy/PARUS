CREATE OR REPLACE PROCEDURE PARUS.Drug_p_Journ_378h_Pril3(Pin_Com   IN NUMBER,
                                                          Pin_Nomen IN VARCHAR2,
                                                          Pin_Store IN VARCHAR2,
                                                          Pin_D1    IN DATE,
                                                          Pin_D2    IN DATE) IS

  v_Store_Rn Parus.Drug_Tbl_Number;

  v_Store_Code VARCHAR2(2000) := ' ';

  Idx INTEGER;

  Line    CONSTANT Pkg_Std.Tstring := 'LINE_1';
  Cell_1  CONSTANT Pkg_Std.Tstring := 'CELL_1';
  Cell_2  CONSTANT Pkg_Std.Tstring := 'CELL_2';
  Cell_3  CONSTANT Pkg_Std.Tstring := 'CELL_3';
  Cell_4  CONSTANT Pkg_Std.Tstring := 'CELL_4';
  Cell_5  CONSTANT Pkg_Std.Tstring := 'CELL_5';
  Cell_6  CONSTANT Pkg_Std.Tstring := 'CELL_6';
  Cell_7  CONSTANT Pkg_Std.Tstring := 'CELL_7';
  Cell_8  CONSTANT Pkg_Std.Tstring := 'CELL_8';
  Cell_9  CONSTANT Pkg_Std.Tstring := 'CELL_9';
  Cell_10 CONSTANT Pkg_Std.Tstring := 'CELL_10';
  Cell_11 CONSTANT Pkg_Std.Tstring := 'CELL_11';
  Cell_12 CONSTANT Pkg_Std.Tstring := 'CELL_12';

  Sh VARCHAR2(1) := 'x';

  v_Nn INTEGER;

  v_Ost1 NUMBER(17, 2);
  v_Ost2 NUMBER(17, 2);

  Cell_Org_Name   CONSTANT Pkg_Std.Tstring := 'ORG_NAME';
  Cell_Store      CONSTANT Pkg_Std.Tstring := 'STORE';
  Cell_Nomen_Name CONSTANT Pkg_Std.Tstring := 'NOMEN_NAME';
  Cell_Dose       CONSTANT Pkg_Std.Tstring := 'DOSA';
  Cell_Sklad_Pole CONSTANT Pkg_Std.Tstring := 'SKLAD_POLE';

  Sblank     VARCHAR2(20) := Get_Options_Str('EmptySymb');
  Sdelimiter VARCHAR2(20) := Get_Options_Str('SeqSymb');
  Sstar      VARCHAR2(20) := Get_Options_Str('StarSymb');
  Squestsymb VARCHAR2(20) := Get_Options_Str('QuestSymb');
  Snotsymb   VARCHAR2(20) := Get_Options_Str('NotSymb');

  s_Nomen VARCHAR2(2000) := REPLACE(REPLACE(Pin_Nomen, Sstar, '%')
                                   ,Squestsymb
                                   ,'_');
  s_Store VARCHAR2(2000) := REPLACE(REPLACE(Pin_Store, Sstar, '%')
                                   ,Squestsymb
                                   ,'_');

  v_Dt1 DATE;
  v_Dt2 DATE;

  v_Prih NUMBER(17, 2);
  v_Rash NUMBER(17, 2);

BEGIN

  IF Pin_D2 < Pin_D1 THEN
    p_Exception(0
               ,'"ƒата с" не может быть больше "дата по"');
  END IF;

  Prsg_Excel.Prepare;
  Prsg_Excel.Sheet_Select(Sh);

  Prsg_Excel.Line_Describe(Line);

  Prsg_Excel.Cell_Describe(Cell_Nomen_Name);
  Prsg_Excel.Cell_Describe(Cell_Dose);

  FOR i IN 1 .. 12 LOOP
    Prsg_Excel.Line_Cell_Describe(Line, 'CELL_' || To_Char(i));
  END LOOP;

  Prsg_Excel.Cell_Describe(Cell_Org_Name);
  Prsg_Excel.Cell_Value_Write(Cell_Org_Name
                             ,Udo_Pkg_Rep.Company_Agnlist_Name(Pin_Com, 1));

  IF Pin_Store IS NOT NULL THEN
    Prsg_Excel.Cell_Describe(Cell_Sklad_Pole);
    Prsg_Excel.Cell_Describe(Cell_Store);
    Prsg_Excel.Cell_Value_Write(Cell_Sklad_Pole, '—клад:');

    SELECT t.Rn
      BULK COLLECT
      INTO v_Store_Rn
      FROM Azsazslistmt t
     WHERE t.Company = Pin_Com
       AND Udo_f_Strinlike(t.Azs_Number, s_Store, Sdelimiter, Sblank, Snotsymb) = 1;

    FOR Cur IN (SELECT Skl.Azs_Number Nmb
                  FROM Azsazslistmt Skl
                  JOIN (SELECT To_Number(Column_Value) Rn FROM TABLE(v_Store_Rn)) r
                    ON r.Rn = Skl.Rn) LOOP
      IF Length(v_Store_Code) < 1800 THEN
        v_Store_Code := v_Store_Code || ',' || Cur.Nmb;
      END IF;
    END LOOP;

    Prsg_Excel.Cell_Value_Write(Cell_Store, Substr(v_Store_Code, 3));

  END IF;

  ----ƒл€ каждой номенклатуры делаем отдельный отчет
  FOR Nom IN (SELECT d.Rn Drn,
                     Nm.Rn Nmrn,
                     d.Nomen_Name,
                     Ei.Meas_Name || ' (' || Up.Quant || Ei.Meas_Mnemo || ' в ' ||
                     Up.Code || ')' Dose
                FROM Dicnomns d
                JOIN Compverlist v
                  ON v.Version = d.Version
                 AND v.Unitcode = 'Nomenclator'
                 AND v.Company = Pin_Com
                JOIN Dicmunts Ei
                  ON Ei.Rn = d.Umeas_Main
                LEFT JOIN Nomnpack Up
                  ON Up.Prn = d.Rn
                JOIN Nommodif Nm
                  ON Nm.Prn = d.Rn
               WHERE Udo_f_Strinlike(d.Nomen_Code
                                    ,s_Nomen
                                    ,Sdelimiter
                                    ,Sblank
                                    ,Snotsymb) = 1) LOOP

    Prsg_Excel.Sheet_Copy(Ssheet_Name_From => Sh, Ssheet_Name_To => Nom.Nmrn);
    Prsg_Excel.Sheet_Select(Nom.Nmrn);
    Prsg_Excel.Cell_Value_Write(Cell_Nomen_Name, Nom.Nomen_Name);
    Prsg_Excel.Cell_Value_Write(Cell_Dose, Nom.Dose);

    --- ÷икл по мес€цам

    FOR i IN 0 .. Trunc(Months_Between(Pin_D2, Pin_D1)) LOOP

      Idx := Prsg_Excel.Line_Append(Line);

      v_Dt1 := Add_Months(Trunc(Pin_D1, 'Month'), i); --- ѕервый день мес€ца
      v_Dt2 := Last_Day(Add_Months(Trunc(Pin_D1, 'Month'), i)) + 1; --  онец последнего дн€ мес€ца

      Prsg_Excel.Cell_Value_Write(Cell_1
                                 ,0
                                 ,Idx
                                 ,Udo_Pkg_Rep.Month_Name(v_Dt1, 1));

      SELECT SUM(Udo_Pkg_Rep.Ost_Nommodif(Pin_Com   => Pin_Com
                                         ,Pin_Nmrn  => Nom.Nmrn
                                         ,Pin_Date  => Trunc(v_Dt1, 'Month')
                                         ,Pin_Store => Skl.Rn
                                         ,Pin_Rej   => 'Q'))
        INTO v_Ost1
        FROM Azsazslistmt Skl
        JOIN (SELECT To_Number(Column_Value) Rn FROM TABLE(v_Store_Rn)) r
          ON r.Rn = Skl.Rn;

      Prsg_Excel.Cell_Value_Write(Cell_2, 0, Idx, v_Ost1);

      SELECT SUM(Udo_Pkg_Rep.Ost_Nommodif(Pin_Com   => Pin_Com
                                         ,Pin_Nmrn  => Nom.Nmrn
                                         ,Pin_Date  => Trunc(v_Dt2, 'Month')
                                         ,Pin_Store => Skl.Rn
                                         ,Pin_Rej   => 'Q'))
        INTO v_Ost2
        FROM Azsazslistmt Skl
        JOIN (SELECT To_Number(Column_Value) Rn FROM TABLE(v_Store_Rn)) r
          ON r.Rn = Skl.Rn;

      Prsg_Excel.Cell_Value_Write(Cell_11, 0, Idx, v_Ost2);

      --- ¬ыыедем движение за мес€ц
      --- сортируем  дате операции, типе операции

      --- ƒвижение за мес€ц
      v_Nn   := 1; --- ѕерва€ строка
      v_Prih := v_Ost1;
      v_Rash := 0;

      FOR Dv IN (
                 --- ƒвижение за мес€ц

                 SELECT Row_Number() Over(PARTITION BY Gy.Prn ORDER BY St.Operdate, St.Oper_Type) Nn,
                         St.Operdate,
                         St.Oper_Type,
                         St.Quant q,
                         CASE St.Unitcode
                           WHEN 'GoodsTransInvoicesToConsumers' THEN
                            Dt1.Doccode
                           WHEN 'IncomingOrders' THEN
                            Dt0.Doccode
                           ELSE
                            Dt2.Doccode
                         END Doc_Type,
                         CASE St.Unitcode
                           WHEN 'GoodsTransInvoicesToConsumers' THEN
                            TRIM(R1.Pref) || '-' || TRIM(R1.Numb)
                           WHEN 'IncomingOrders' THEN
                            TRIM(i.Indocpref) || '-' || TRIM(i.Indocnumb)
                           ELSE
                            TRIM(R2.Pref) || '-' || TRIM(R2.Numb)
                         END Doc_Nmb,
                         CASE St.Unitcode
                           WHEN 'GoodsTransInvoicesToConsumers' THEN
                            To_Char(R1.Docdate, 'DD.MM.YYYY')
                           WHEN 'IncomingOrders' THEN
                            To_Char(i.Indocdate, 'DD.MM.YYYY')
                           ELSE
                            To_Char(R2.Docdate, 'DD.MM.YYYY')
                         END Doc_Date,
                         Coalesce(Ag.Agnabbr, S2.Azs_Number) Supp
                   FROM Goodsparties Gp
                   JOIN Goodssupply Gy
                     ON Gy.Prn = Gp.Rn
                    AND Gy.Company = Gp.Company
                   JOIN Storeoperjourn St
                     ON St.Goodssupply = Gy.Rn

                   LEFT JOIN Doclinks Dl0
                     ON Dl0.Out_Document = St.Rn
                    AND Dl0.In_Unitcode = 'IncomingOrders'
                    AND Dl0.Out_Company = St.Company
                    AND Dl0.In_Company = Dl0.Out_Company
                    AND Dl0.Out_Unitcode = 'StoreOpersJournal'
                   LEFT JOIN Inorders i
                     ON i.Rn = Dl0.In_Document
                   LEFT JOIN Doctypes Dt0
                     ON Dt0.Rn = i.Indoctype

                   LEFT JOIN Doclinks Dl1
                     ON Dl1.Out_Document = St.Rn
                    AND Dl1.In_Unitcode = 'GoodsTransInvoicesToConsumers'
                    AND Dl1.Out_Company = St.Company
                    AND Dl1.In_Company = Dl1.Out_Company
                    AND Dl1.Out_Unitcode = 'StoreOpersJournal'
                   LEFT JOIN Transinvcust R1
                     ON R1.Rn = Dl1.In_Document
                   LEFT JOIN Doctypes Dt1
                     ON Dt1.Rn = R1.Doctype

                   LEFT JOIN Doclinks Dl2
                     ON Dl2.Out_Document = St.Rn
                    AND Dl2.In_Unitcode = 'GoodsTransInvoicesToDepts'
                    AND Dl2.Out_Company = St.Company
                    AND Dl2.In_Company = Dl2.Out_Company
                    AND Dl2.Out_Unitcode = 'StoreOpersJournal'
                   LEFT JOIN Transinvdept R2
                     ON R2.Rn = Dl2.In_Document
                   LEFT JOIN Doctypes Dt2
                     ON Dt2.Rn = R2.Doctype

                   JOIN (SELECT To_Number(Column_Value) Rn FROM TABLE(v_Store_Rn)) r
                     ON r.Rn = Gy.Store

                   LEFT JOIN Agnlist Ag
                     ON Ag.Rn = i.Contragent
                   LEFT JOIN Azsazslistmt S2
                     ON S2.Rn = R2.Store

                  WHERE Gp.Nommodif = Nom.Nmrn
                    AND Gp.Company = Pin_Com
                    AND St.Operdate BETWEEN v_Dt1 AND v_Dt2 - 1
                    AND St.Company = Gp.Company

                  ORDER BY 1

                 ---ѕриход по всем парти€м

                 ) LOOP

        IF Dv.Nn != v_Nn THEN
          Idx  := Prsg_Excel.Line_Append(Line);
          v_Nn := Dv.Nn;
        END IF;

        IF Dv.Oper_Type = 1 THEN
          --- приход
          Prsg_Excel.Cell_Value_Write(Cell_3, 0, Idx, Dv.Supp);
          Prsg_Excel.Cell_Value_Write(Cell_4
                                     ,0
                                     ,Idx
                                     ,Dv.Doc_Type || Cr || Dv.Doc_Nmb || Cr ||
                                      Dv.Doc_Date);
          v_Prih := v_Prih + Dv.q;
          Prsg_Excel.Cell_Value_Write(Cell_5, 0, Idx, Dv.q);
          Prsg_Excel.Cell_Value_Write(Cell_6, 0, Idx, v_Prih);
        ELSE
          Prsg_Excel.Cell_Value_Write(Cell_7
                                     ,0
                                     ,Idx
                                     ,To_Char(Dv.Operdate, 'DD.MM.YYYY'));
          Prsg_Excel.Cell_Value_Write(Cell_8
                                     ,0
                                     ,Idx
                                     ,Dv.Doc_Type || Cr || Dv.Doc_Nmb || Cr ||
                                      Dv.Doc_Date);
          v_Rash := v_Rash + Dv.q;
          Prsg_Excel.Cell_Value_Write(Cell_9, 0, Idx, Dv.q);
          Prsg_Excel.Cell_Value_Write(Cell_10, 0, Idx, v_Rash);
        END IF;

      END LOOP;

    END LOOP; -- по мес€ца

    Idx := 0;

  END LOOP; --по модификаци€м

  IF Idx IS NOT NULL THEN
    Prsg_Excel.Sheet_Delete(Sh);
    Prsg_Excel.Line_Delete(Line);
  END IF;

  NULL;

END;
---grant execute on  DRUG_P_JOURN_378H_PRIL3 to public;
/
