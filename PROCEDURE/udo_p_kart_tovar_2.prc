CREATE OR REPLACE PROCEDURE PARUS.udo_p_kart_tovar_2(pin_idn IN NUMBER,
                                                     pin_com IN NUMBER,
                                                     pin_uni IN VARCHAR2,
                                                     pin_d1  IN DATE,
                                                     pin_d2  IN DATE,
                                                     pin_oei IN NUMBER,
                                                     pin_skip_pricea IN NUMBER,  --- Срыть столбец цены остатка на дату
                                                     pin_store IN VARCHAR2
                                                     ) AS
  /* описание отчета */
  -- рабочий лист
  sh CONSTANT pkg_std.tstring := 'КАРТОЧКА ТМЦ';
  scur_sheet_name pkg_std.tstring;
  --шапка отчета
  cell_org_name   CONSTANT pkg_std.tstring := 'ORG_NAME';
  cell_zag1       CONSTANT pkg_std.tstring := 'ZAG1';
  cell_modif_name CONSTANT pkg_std.tstring := 'MODIF_NAME';
  cell_grp_1      CONSTANT pkg_std.tstring := 'GRP_1';
  cell_ed_izm     CONSTANT pkg_std.tstring := 'ED_IZM';
  cell_pbe        CONSTANT pkg_std.tstring := 'PBE';
  cell_ek_klass   CONSTANT pkg_std.tstring := 'EK_KLASS';
  cell_strras     CONSTANT pkg_std.tstring := 'STRRAS';
  cell_ost_1 CONSTANT pkg_std.tstring := 'OST_1';
  cell_dvi   CONSTANT pkg_std.tstring := 'DVI';
  cell_ost_3 CONSTANT pkg_std.tstring := 'OST_3';
  lat_name            CONSTANT pkg_std.tstring := 'LAT_NAME';
  cell_modif_name_lat CONSTANT pkg_std.tstring := 'MODIF_NAME_LAT';
  --- Строка таблицы остатки на КОНЕЦ
  line1        CONSTANT pkg_std.tstring := 'LINE1';
  cell_npp_1   CONSTANT pkg_std.tstring := 'NPP_1';
  cell_ser_1   CONSTANT pkg_std.tstring := 'SER_1';
  cell_srok_1  CONSTANT pkg_std.tstring := 'SROK_1';
  cell_part_1  CONSTANT pkg_std.tstring := 'PART_1';
  cell_price_1 CONSTANT pkg_std.tstring := 'PRICE_1';
  cell_quant_1 CONSTANT pkg_std.tstring := 'QUANT_1';
  cell_summa_1 CONSTANT pkg_std.tstring := 'SUMMA_1';
  cell_post_1  CONSTANT pkg_std.tstring := 'POST_1';
  --- Cтрока таблицы ОБОРОТЫ
  line_det       CONSTANT pkg_std.tstring := 'LINE_DET';
  cell_npp_2     CONSTANT pkg_std.tstring := 'NPP_2';
  cell_oper_date CONSTANT pkg_std.tstring := 'OPER_DATE';
  cell_doc_t     CONSTANT pkg_std.tstring := 'DOC_T';
  cell_oper_t    CONSTANT pkg_std.tstring := 'OPER_T';
  cell_ser_2     CONSTANT pkg_std.tstring := 'SER_2';
  cell_part_code CONSTANT pkg_std.tstring := 'PART_CODE';
  cell_otkuda    CONSTANT pkg_std.tstring := 'OTKUDA';
  cell_kuda      CONSTANT pkg_std.tstring := 'KUDA';
  cell_prihod    CONSTANT pkg_std.tstring := 'PRIHOD';
  cell_rashod    CONSTANT pkg_std.tstring := 'RASHOD';
  cell_price_2   CONSTANT pkg_std.tstring := 'PRICE_2';
  cell_summa2    CONSTANT pkg_std.tstring := 'SUMMA2';
  cell_s_2       CONSTANT pkg_std.tstring := 'S_2';
  cell_q_2       CONSTANT pkg_std.tstring := 'Q_2';
  --- Строка таблицы остатки на НАЧАЛО
  line3        CONSTANT pkg_std.tstring := 'LINE3';
  cell_npp_3   CONSTANT pkg_std.tstring := 'NPP_3';
  cell_ser_3   CONSTANT pkg_std.tstring := 'SER_3';
  cell_srok_3  CONSTANT pkg_std.tstring := 'SROK_3';
  cell_part_3  CONSTANT pkg_std.tstring := 'PART_3';
  cell_price_3 CONSTANT pkg_std.tstring := 'PRICE_3';
  cell_quant_3 CONSTANT pkg_std.tstring := 'QUANT_3';
  cell_summa_3 CONSTANT pkg_std.tstring := 'SUMMA_3';
  cell_post_3  CONSTANT pkg_std.tstring := 'POST_3';
  
  col_p2  CONSTANT pkg_std.tstring := 'COL_P2';
  
  
  idx    INTEGER;
  i_card INTEGER := 0;
  v_ost_s_end NUMBER(17, 2) := 0;
  v_ost_q_end NUMBER(17, 2) := 0;
  v_ost_s_tek NUMBER(17, 2);
  v_ost_q_tek NUMBER(17, 2);
  out_otkogo_code VARCHAR2(2000);
  out_otkogo_name VARCHAR2(2000);
  out_komu_code   VARCHAR2(2000);
  out_komu_name   VARCHAR2(2000);
  v_skl_all VARCHAR2(2000);
  v_fl INTEGER:=0;
 
  ---V_Q_UPAC number(17,2); --- Количество в упаковке

 PROCEDURE kont(pin_st_rn    IN NUMBER,
                 pin_uni      IN VARCHAR2,
                 pin_opertype IN NUMBER,
                 otkogo_code  OUT VARCHAR2,
                 otkogo_name  OUT VARCHAR2,
                 komu_code    OUT VARCHAR2,
                 komu_name    OUT VARCHAR2) IS
  BEGIN  --- Найдем конттрагента записи ЖСО
  
    CASE pin_uni
      WHEN 'IncomingOrders' THEN
        BEGIN
          SELECT a.agnabbr, a.agnname, skl.azs_number, skl.azs_name
            INTO otkogo_code, otkogo_name, komu_code, komu_name
            FROM parus.doclinks     l,
                 parus.inorders     i,
                 parus.faceacc      f,
                 parus.agnlist      a,
                 parus.azsazslistmt skl
           WHERE l.out_document = pin_st_rn
             AND l.out_company = pin_com
             AND l.out_unitcode = 'StoreOpersJournal'
             AND l.in_unitcode = 'IncomingOrders'
             AND l.in_company = l.out_company
             AND i.rn = l.in_document
             AND f.rn = i.faceacc
             AND a.rn = f.agent
             AND skl.rn = i.store;
        EXCEPTION
          WHEN no_data_found THEN
            otkogo_code := 'x';
            otkogo_name := 'x';
            komu_code   := 'x';
            komu_name   := 'x';
        END;
      WHEN 'GoodsTransInvoicesToDepts' THEN
        BEGIN
          SELECT CASE pin_opertype
                    WHEN 0 THEN
                    skl_out.azs_number
                   ELSE
                    skl_in.azs_number
                 END,
                 CASE pin_opertype
                   WHEN 0 THEN
                    skl_out.azs_name
                   ELSE
                    skl_in.azs_name
                 END,
                 CASE pin_opertype
                   WHEN 0 THEN
                    skl_in.azs_number
                   ELSE
                    skl_out.azs_number
                 END,
                 CASE pin_opertype
                   WHEN 0 THEN
                    skl_in.azs_name
                   ELSE
                    skl_out.azs_name
                 END
            INTO otkogo_code, otkogo_name, komu_code, komu_name
            FROM parus.doclinks     l,
                 parus.transinvdept td,
                 parus.azsazslistmt skl_in,
                 parus.azsazslistmt skl_out
           WHERE l.out_document = pin_st_rn
             AND l.out_company = pin_com
             AND l.out_unitcode = 'StoreOpersJournal'
             AND l.in_unitcode = 'GoodsTransInvoicesToDepts'
             AND l.in_company = l.out_company
             AND td.rn = l.in_document
             AND td.in_store = skl_in.rn(+)
             AND td.store = skl_out.rn;
        EXCEPTION
          WHEN no_data_found THEN
            otkogo_code := 'x';
            otkogo_name := 'x';
            komu_code   := 'x';
            komu_name   := 'x';
        END;
      WHEN 'GoodsTransInvoicesToConsumers' THEN
        BEGIN
          SELECT CASE pin_opertype
                   WHEN 0 THEN
                    skl.azs_number
                   ELSE
                    ag.agnabbr
                 END,
                 CASE pin_opertype
                   WHEN 0 THEN
                    skl.azs_name
                   ELSE
                    ag.agnname
                 END,
                 CASE pin_opertype
                   WHEN 0 THEN
                    ag.agnabbr
                   ELSE
                    skl.azs_number
                 END,
                 CASE pin_opertype
                   WHEN 0 THEN
                    ag.agnname
                   ELSE
                    skl.azs_name
                 END
            INTO otkogo_code, otkogo_name, komu_code, komu_name
            FROM doclinks l, transinvcust td, azsazslistmt skl, agnlist ag
           WHERE l.out_document = pin_st_rn
             AND l.out_company = pin_com
             AND l.out_unitcode = 'StoreOpersJournal'
             AND l.in_unitcode = 'GoodsTransInvoicesToConsumers'
             AND l.in_company = l.out_company
             AND td.rn = l.in_document
             AND td.store = skl.rn
             AND td.agent = ag.rn(+);
        EXCEPTION
          WHEN no_data_found THEN
            otkogo_code := 'x';
            otkogo_name := 'x';
            komu_code   := 'x';
            komu_name   := 'x';
        END;
      ELSE
        otkogo_code := 'xx';
        otkogo_name := 'xx';
        komu_code   := 'xx';
        komu_name   := 'xx';
    END CASE;
  END;

BEGIN
  /* пролог */
  prsg_excel.prepare;
  /* установка текущего рабочего листа */
  prsg_excel.sheet_select(sh);
  /* описание */
  -- Заголовок
  prsg_excel.cell_describe(cell_org_name); --
  prsg_excel.cell_describe(cell_zag1);
  prsg_excel.cell_describe(cell_modif_name); --
  prsg_excel.cell_describe(cell_grp_1); --    
  prsg_excel.cell_describe(cell_ed_izm); ---
  prsg_excel.cell_describe(cell_pbe); ---    
  prsg_excel.cell_describe(cell_ek_klass); --- 
  prsg_excel.cell_describe(cell_strras); ---  
  prsg_excel.cell_describe(cell_ost_1);
  prsg_excel.cell_describe(cell_dvi);
  prsg_excel.cell_describe(cell_ost_3);
  ---- Столбцы
  
  prsg_excel.column_describe(col_p2);
  IF pin_skip_pricea=1 THEN prsg_excel.column_delete(col_p2); END IF;
  
  --- Строки таблицы
  prsg_excel.line_describe(lat_name);
  prsg_excel.cell_describe(cell_modif_name_lat);
  prsg_excel.line_describe(line1);
  prsg_excel.line_cell_describe(line1, cell_npp_1);
  prsg_excel.line_cell_describe(line1, cell_ser_1);
  prsg_excel.line_cell_describe(line1, cell_srok_1);
  prsg_excel.line_cell_describe(line1, cell_part_1);
  prsg_excel.line_cell_describe(line1, cell_price_1);
  prsg_excel.line_cell_describe(line1, cell_quant_1);
  prsg_excel.line_cell_describe(line1, cell_summa_1);
  prsg_excel.line_cell_describe(line1, cell_post_1);
  prsg_excel.line_describe(line_det);
  prsg_excel.line_cell_describe(line_det, cell_npp_2);
  prsg_excel.line_cell_describe(line_det, cell_oper_date);
  prsg_excel.line_cell_describe(line_det, cell_doc_t);
  prsg_excel.line_cell_describe(line_det, cell_oper_t);
  prsg_excel.line_cell_describe(line_det, cell_ser_2);
  prsg_excel.line_cell_describe(line_det, cell_part_code);
  prsg_excel.line_cell_describe(line_det, cell_otkuda);
  prsg_excel.line_cell_describe(line_det, cell_kuda);
  prsg_excel.line_cell_describe(line_det, cell_prihod);
  prsg_excel.line_cell_describe(line_det, cell_rashod);
  prsg_excel.line_cell_describe(line_det, cell_price_2);
  prsg_excel.line_cell_describe(line_det, cell_summa2);
  prsg_excel.line_cell_describe(line_det, cell_s_2);
  prsg_excel.line_cell_describe(line_det, cell_q_2);
  prsg_excel.line_describe(line3);
  prsg_excel.line_cell_describe(line3, cell_npp_3);
  prsg_excel.line_cell_describe(line3, cell_ser_3);
  prsg_excel.line_cell_describe(line3, cell_srok_3);
  prsg_excel.line_cell_describe(line3, cell_part_3);
  prsg_excel.line_cell_describe(line3, cell_price_3);
  prsg_excel.line_cell_describe(line3, cell_quant_3);
  prsg_excel.line_cell_describe(line3, cell_summa_3);
  prsg_excel.line_cell_describe(line3, cell_post_3);
  prsg_excel.cell_value_write(cell_org_name,
                              parus.udo_pkg_rep.company_agnlist_name(pin_com => pin_com,
                                                                     pin_rej => 1));
  prsg_excel.cell_value_write(cell_ost_1,
                              'Остаток на ' || to_char(pin_d2, 'DD.MM.YYYY'));
  prsg_excel.cell_value_write(cell_dvi,
                              'Движение за период с  ' || to_char(pin_d1, 'DD.MM.YYYY') ||
                              ' по ' || to_char(pin_d2, 'DD.MM.YYYY'));
  prsg_excel.cell_value_write(cell_ost_3,
                              'Остаток на ' || to_char(pin_d1, 'DD.MM.YYYY'));
                              
  --- Найдем                               
            
                              
  CASE pin_uni --- Отчет по запустили из окна "Партии товара"
    WHEN 'GoodsParties' THEN
      FOR cur1 IN (SELECT DISTINCT parus.udo_f_return_goodsparties_pbe(nrn      => gp.rn,
                                                                       ncompany => gp.company) pbe,
                                   parus.udo_f_return_goodsparties_sr(nrn      => gp.rn,
                                                                      ncompany => gp.company) sr,
                                   parus.UDO_F_RETURN_GOODSPART_KOSGU(nrn      => gp.rn,
                                                                      ncompany => gp.company) ec,
                                   nm.modif_code,
                                   nm.modif_name,
                                   pak.code upac,
                                   parus.udo_pkg_rep.gr_ls(pin_com     => gp.company,
                                                           pin_nom     => nm.prn,
                                                           pin_vid_res => 'CODE', PIN_D1 => PIN_D1, PIN_d2 => PIN_D2) gls,
                                   ei.meas_mnemo oei,
                                   nm.rn nmrn,
                                   nvl(nmp.rn, 0) nmprn,
                                   parus.udo_pkg_rep.docs_props_vals_s(pin_com  => pin_com,
                                                                       pin_rej  => 1,
                                                                       pin_doc  => nm.rn,
                                                                       pin_code => 'Латинское наим',
                                                                       pin_uni  => 'NomenclatorModification') lat_name,
                                   nvl(pak.quant,1) upac_q                                    
                     FROM parus.selectlist    l,
                          parus.goodsparties  gp, goodssupply gy, azsazslistmt skl,
                          parus.nommodif      nm,
                          parus.nomnmodifpack nmp,
                          parus.nomnpack      pak,
                          parus.dicnomns      nom,
                          parus.dicmunts      ei
                    WHERE l.ident = pin_idn
                      AND l.company = pin_com
                      AND l.authid = user
                      AND gp.rn = l.document
                      AND gp.rn = gy.prn
                        AND skl.rn = gy.store
                        AND (pin_store IS NULL OR skl.azs_number = pin_store)
                      AND gp.nommodif = nm.rn
                      AND nom.rn = nm.prn
                      AND nom.umeas_main = ei.rn
                      AND gp.nomnmodifpack = nmp.rn(+)
                      AND nmp.nomenpack = pak.rn(+)
                    ORDER BY nm.modif_code) LOOP
        i_card := i_card + 1;
        -- установка рабочего листа
        scur_sheet_name := prsg_excel.form_sheet_name(cur1.modif_code || '_' || i_card);
        prsg_excel.sheet_copy(sh, scur_sheet_name);
        prsg_excel.sheet_select(scur_sheet_name);
        prsg_excel.cell_value_write(cell_modif_name,
                                    cur1.modif_name || ' (' || cur1.modif_code || ')');
        ---- Латинское наименование, если оно есть
        IF cur1.lat_name IS NOT NULL THEN
          prsg_excel.cell_value_write(cell_modif_name_lat, cur1.lat_name);
        ELSE
          prsg_excel.line_delete(lat_name);
        END IF;
        prsg_excel.cell_value_write(cell_grp_1, cur1.gls);
        prsg_excel.cell_value_write(cell_pbe, cur1.pbe);
        prsg_excel.cell_value_write(cell_strras, cur1.sr);
        prsg_excel.cell_value_write(cell_ek_klass, cur1.ec);
        IF pin_oei = 1 THEN 
        prsg_excel.cell_value_write(cell_ed_izm, cur1.oei);
        ELSE 
        prsg_excel.cell_value_write(cell_ed_izm, cur1.upac);
        END IF;
        
        ---- Выводим остатки на начало и конец периода
        FOR cur2 IN (SELECT gp.rn,
                            gp.sernumb,
                            gp.expiry_date,
                            par.code part_code,
                            (SELECT MAX(p.agnname)
                               FROM parus.inorders po, parus.agnlist p
                              WHERE po.party = gp.indoc
                                AND po.company = gp.company
                                AND p.rn = po.contragent) sagent,
                            (SELECT SUM(parus.udo_pkg_rep.ost_gy(pin_com  => gy.company,
                                                                 pin_gy   => gy.rn,
                                                                 pin_date => pin_d1,
                                                                 pin_rej  => 'Q'))
                               FROM parus.goodssupply gy,  azsazslistmt skl
                              WHERE gy.prn = gp.rn
                              AND skl.rn = gy.store
                        AND (pin_store IS NULL OR skl.azs_number = pin_store)) q3,
                            (SELECT SUM(parus.udo_pkg_rep.ost_gy(pin_com  => gy.company,
                                                                 pin_gy   => gy.rn,
                                                                 pin_date => pin_d1,
                                                                 pin_rej  => 'S'))
                               FROM parus.goodssupply gy,  azsazslistmt skl
                              WHERE gy.prn = gp.rn
                              AND skl.rn = gy.store
                        AND (pin_store IS NULL OR skl.azs_number = pin_store)) s3,
                            (SELECT SUM(parus.udo_pkg_rep.ost_gy(pin_com  => gy.company,
                                                                 pin_gy   => gy.rn,
                                                                 pin_date => pin_d2+1, -- Начало следующего дня
                                                                 pin_rej  => 'Q'))
                               FROM parus.goodssupply gy,  azsazslistmt skl
                              WHERE gy.prn = gp.rn
                              AND skl.rn = gy.store
                        AND (pin_store IS NULL OR skl.azs_number = pin_store)) q1,
                            (SELECT SUM(parus.udo_pkg_rep.ost_gy(pin_com  => gy.company,
                                                                 pin_gy   => gy.rn,
                                                                 pin_date => pin_d2+1,  -- Начало следующего дня
                                                                 pin_rej  => 'S'))
                               FROM parus.goodssupply gy,  azsazslistmt skl
                              WHERE gy.prn = gp.rn
                              AND skl.rn = gy.store
                        AND (pin_store IS NULL OR skl.azs_number = pin_store)) s1,
                            (SELECT MAX(parus.udo_f_return_gy_regprice_oei(gy.rn, pin_d1))
                               FROM parus.goodssupply gy,  azsazslistmt skl
                              WHERE gy.prn = gp.rn) price3,
                            (SELECT MAX(parus.udo_f_return_gy_regprice_oei(gy.rn, pin_d2))
                               FROM parus.goodssupply gy,  azsazslistmt skl
                              WHERE gy.prn = gp.rn
                              AND skl.rn = gy.store
                        AND (pin_store IS NULL OR skl.azs_number = pin_store)) price1
                       FROM parus.selectlist l, parus.goodsparties gp, parus.incomdoc par
                      WHERE l.ident = pin_idn
                        AND l.company = pin_com
                        AND l.authid = user
                        AND gp.rn = l.document
                        AND gp.company = pin_com
                        AND gp.nommodif = cur1.nmrn                                               
                        AND nvl(gp.nomnmodifpack, 0) = cur1.nmprn
                        AND nvl(parus.udo_f_return_goodsparties_pbe(nrn      => gp.rn,
                                                                    ncompany => gp.company),
                                'PBE') = nvl(cur1.pbe, 'PBE')
                        AND nvl(parus.udo_f_return_goodsparties_sr(nrn      => gp.rn,
                                                                   ncompany => gp.company),
                                'SR') = nvl(cur1.sr, 'SR')
                        AND nvl(parus.UDO_F_RETURN_GOODSPART_KOSGU(nrn      => gp.rn,
                                                                   ncompany => gp.company),
                                'EC') = nvl(cur1.ec, 'EC')
                        AND par.rn = gp.indoc
                        AND par.company = pin_com
                      ORDER BY 4) LOOP
                       v_fl:=1;
          --- Остатки на конец периода
          idx := prsg_excel.line_append(line1);
          prsg_excel.cell_value_write(cell_npp_1, 0, idx, idx);
          prsg_excel.cell_value_write(cell_ser_1, 0, idx, cur2.sernumb);
          prsg_excel.cell_value_write(cell_srok_1, 0, idx, cur2.expiry_date);
          prsg_excel.cell_value_write(cell_part_1, 0, idx, cur2.part_code);
          IF pin_oei =1 THEN 
          prsg_excel.cell_value_write(cell_price_1, 0, idx, cur2.price1);
          prsg_excel.cell_value_write(cell_quant_1, 0, idx, cur2.q1);
          ELSE
          prsg_excel.cell_value_write(cell_price_1, 0, idx, cur2.price1*cur1.upac_q);
          prsg_excel.cell_value_write(cell_quant_1, 0, idx, cur2.q1/cur1.upac_q);  
          END IF;
          
          
          prsg_excel.cell_value_write(cell_summa_1, 0, idx, cur2.s1);
          prsg_excel.cell_value_write(cell_post_1, 0, idx, cur2.sagent);
          v_ost_s_end := v_ost_s_end + cur2.s1;
          v_ost_q_end := v_ost_q_end + cur2.q1;
          -- Остатки на начало периода   
          idx := prsg_excel.line_append(line3);
          prsg_excel.cell_value_write(cell_npp_3, 0, idx, idx);
          prsg_excel.cell_value_write(cell_ser_3, 0, idx, cur2.sernumb);
          prsg_excel.cell_value_write(cell_srok_3, 0, idx, cur2.expiry_date);
          prsg_excel.cell_value_write(cell_part_3, 0, idx, cur2.part_code);
          IF pin_oei = 1 THEN
          prsg_excel.cell_value_write(cell_price_3, 0, idx, cur2.price3); --- если цена не равна расчетной, покрасим ее в красный цвет 
          prsg_excel.cell_value_write(cell_quant_3, 0, idx, cur2.q3);
          ELSE
          prsg_excel.cell_value_write(cell_price_3, 0, idx, cur2.price3*cur1.upac_q); --- если цена не равна расчетной, покрасим ее в красный цвет 
          prsg_excel.cell_value_write(cell_quant_3, 0, idx, cur2.q3/cur1.upac_q); 
          END IF;
          
          prsg_excel.cell_value_write(cell_summa_3, 0, idx, cur2.s3);
          prsg_excel.cell_value_write(cell_post_3, 0, idx, cur2.sagent);
        END LOOP; --- Остаток по партии
        -- обороты за период  
        v_ost_s_tek := v_ost_s_end;
        v_ost_q_tek := v_ost_q_end;
        FOR det IN (SELECT st.unitcode,
                           st.rn,
                           st.company,
                           st.operdate,
                           dt.doccode || ' ' || TRIM(st.docpref) || '-' || TRIM(st.docnumb) ||
                           ' от ' || to_char(st.docdate, 'DD.MM.YYYY') doc_t,
                           gp.sernumb,
                           par.code part_n,
                           st.oper_type,
                           st.quant,
                           st.summtax,
                           CASE st.quant
                             WHEN 0 THEN
                              0
                             ELSE
                              round(st.summtax / st.quant, 2)
                           END price
                      FROM parus.selectlist     l,
                           parus.goodsparties   gp,
                           parus.goodssupply    gy,
                           parus.azsazslistmt skl,
                           parus.storeoperjourn st,
                           parus.doctypes       dt,
                           parus.incomdoc       par
                     WHERE l.ident = pin_idn
                       AND l.company = pin_com
                       AND l.authid = user
                       AND gp.rn = l.document
                       AND gp.company = pin_com
                       AND gp.nommodif = cur1.nmrn
                       AND nvl(gp.nomnmodifpack, 0) = cur1.nmprn
                       AND nvl(parus.udo_f_return_goodsparties_pbe(nrn      => gp.rn,
                                                                   ncompany => gp.company),
                               'PBE') = nvl(cur1.pbe, 'PBE')
                       AND nvl(parus.udo_f_return_goodsparties_sr(nrn      => gp.rn,
                                                                  ncompany => gp.company),
                               'SR') = nvl(cur1.sr, 'SR')
                       AND nvl(parus.UDO_F_RETURN_GOODSPART_KOSGU(nrn      => gp.rn,
                                                                  ncompany => gp.company),
                               'EC') = nvl(cur1.ec, 'EC')
                       AND gy.prn = gp.rn
                       AND gy.store = skl.rn
                       AND (pin_store IS NULL OR skl.azs_number = pin_store)
                       AND st.goodssupply = gy.rn
                       AND st.signplan != 1
                       AND st.operdate BETWEEN pin_d1 AND pin_d2
                       AND dt.rn = st.doctype
                       AND par.rn = gp.indoc
                     ORDER BY st.operdate DESC, st.oper_type, par.code) LOOP
          kont(det.rn,
               det.unitcode,
               det.oper_type,
               out_otkogo_code,
               out_otkogo_name,
               out_komu_code,
               out_komu_name);
          idx := prsg_excel.line_append(line_det);
          prsg_excel.cell_value_write(cell_npp_2, 0, idx, idx);
          prsg_excel.cell_value_write(cell_oper_date,
                                      0,
                                      idx,
                                      to_char(det.operdate, 'DD.MM.YYYY'));
          prsg_excel.cell_value_write(cell_doc_t, 0, idx, det.doc_t);
          prsg_excel.cell_value_write(cell_oper_t,
                                      0,
                                      idx,
                                      CASE det.oper_type WHEN 1 THEN 'приход' ELSE 'расход' END);
          parus.prsg_excel.cell_attribute_set(cell_oper_t,
                                              0,
                                              idx,
                                              'Interior.ColorIndex',
                                              (CASE det.oper_type WHEN 1 THEN 35 ELSE 2 END));
          prsg_excel.cell_value_write(cell_ser_2, 0, idx, det.sernumb);
          prsg_excel.cell_value_write(cell_part_code,
                                      0,
                                      idx,
                                      (CASE instr(det.part_n, '-') WHEN 0 THEN det.part_n ELSE
                                       substr(det.part_n,
                                              -length(det.part_n) + instr(det.part_n, '-', -1)) END));
         
        IF pin_oei =1 THEN        
         prsg_excel.cell_value_write(cell_prihod,
                                      0,
                                      idx,
                                      (CASE det.oper_type WHEN 1 THEN det.quant ELSE 0 END));
          prsg_excel.cell_value_write(cell_rashod,
                                      0,
                                      idx,
                                      (CASE det.oper_type WHEN 1 THEN 0 ELSE det.quant END));
          prsg_excel.cell_value_write(cell_price_2, 0, idx, det.price);
          prsg_excel.cell_value_write(cell_q_2, 0, idx, v_ost_q_tek);
             ELSE
          prsg_excel.cell_value_write(cell_prihod,
                                      0,
                                      idx,
                                      (CASE det.oper_type WHEN 1 THEN det.quant/cur1.upac_q ELSE 0 END));
          prsg_excel.cell_value_write(cell_rashod,
                                      0,
                                      idx,
                                      (CASE det.oper_type WHEN 1 THEN 0 ELSE det.quant/cur1.upac_q END));
          prsg_excel.cell_value_write(cell_price_2, 0, idx, det.price*cur1.upac_q);
          prsg_excel.cell_value_write(cell_q_2, 0, idx, v_ost_q_tek/cur1.upac_q);          
          END IF;
          
          prsg_excel.cell_value_write(cell_summa2, 0, idx, det.summtax);
          prsg_excel.cell_value_write(cell_s_2, 0, idx, v_ost_s_tek);
          v_ost_s_tek := v_ost_s_tek - det.summtax * (2 * det.oper_type - 1);
          v_ost_q_tek := v_ost_q_tek - det.quant * (2 * det.oper_type - 1);
          
          prsg_excel.cell_value_write(cell_otkuda, 0, idx, out_otkogo_name);
          prsg_excel.cell_value_write(cell_kuda, 0, idx, out_komu_name);
        END LOOP; --- Строка движения
        ---- Найдем все склады которые попадут в отчет
        v_skl_all := '';
        FOR skl IN (SELECT DISTINCT skl.azs_name skl
                      FROM parus.selectlist   l,
                           parus.goodsparties gp,
                           parus.goodssupply  gy,
                           parus.azsazslistmt skl
                     WHERE l.ident = pin_idn
                       AND l.company = pin_com
                       AND l.authid = user
                       AND gp.rn = l.document
                       AND gp.company = pin_com
                       AND gp.nommodif = cur1.nmrn
                       AND nvl(gp.nomnmodifpack, 0) = cur1.nmprn
                       AND nvl(parus.udo_f_return_goodsparties_pbe(nrn      => gp.rn,
                                                                   ncompany => gp.company),
                               'PBE') = nvl(cur1.pbe, 'PBE')
                       AND nvl(parus.udo_f_return_goodsparties_sr(nrn      => gp.rn,
                                                                  ncompany => gp.company),
                               'SR') = nvl(cur1.sr, 'SR')
                       AND nvl(parus.UDO_F_RETURN_GOODSPART_KOSGU(nrn      => gp.rn,
                                                                  ncompany => gp.company),
                               'EC') = nvl(cur1.ec, 'EC')
                       AND gy.prn = gp.rn
                       AND gy.store = skl.rn) LOOP
        IF length(v_skl_all) < 1500 THEN  
         v_skl_all := v_skl_all || '; ' || skl.skl;
        END IF; 
        END LOOP;
        IF length(v_skl_all) > 255 THEN
          v_skl_all := substr(v_skl_all, 1, 250) || '...';
        END IF;
        prsg_excel.cell_value_write(cell_zag1,
                                    'Карточка' || chr(10) || 'за период с ' ||
                                    to_char(pin_d1, 'DD.MM.YYYY') || ' по ' ||
                                    to_char(pin_d2, 'DD.MM.YYYY') || chr(10) || 'по складам' ||
                                    substr(v_skl_all, 2));
        prsg_excel.line_delete(line1);
        prsg_excel.line_delete(line_det);
        prsg_excel.line_delete(line3);
      END LOOP; --- Страница карточки
    ELSE
      p_exception(0,
                  'Из данного раздела печать карточки еще не настроена');
  END CASE;
  p_exception(v_fl, 'По указанным данным данных не найдено');
  prsg_excel.sheet_delete(sh);
END;
/*
  grant execute on parus.UDO_P_KART_TOVAR_2 to public;
  */
/
