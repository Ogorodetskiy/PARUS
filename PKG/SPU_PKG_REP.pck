CREATE OR REPLACE PACKAGE PARUS.SPU_PKG_REP IS

  FUNCTION SPU_AGNLIST_ADDR(PIN_RN IN NUMBER, PIN_FORMAT IN VARCHAR2 DEFAULT 'CPRYTSHBLF', pin_DELIM IN VARCHAR2 DEFAULT ', ')
    RETURN VARCHAR2;
  FUNCTION SPU_TALON_STAFF(PIN_DOC IN NUMBER, PIN_VID IN VARCHAR2 DEFAULT NULL) RETURN SYS_REFCURSOR;
  FUNCTION SPU_USLUG_STAFF(PIN_DOC IN NUMBER, PIN_VID IN VARCHAR2 DEFAULT NULL) RETURN SYS_REFCURSOR;

  FUNCTION ADMIN_FIO(PIN_COM IN NUMBER, PIN_RES IN number) RETURN varchar2;
  FUNCTION ADMIN_DOL(PIN_COM IN NUMBER, PIN_RES IN number default 0) RETURN varchar2;
  FUNCTION ADMIN_ABBR(PIN_COM IN NUMBER) RETURN varchar2; --- Мнемокод контрагента администратора
  FUNCTION ADMIN_USER(PIN_COM IN NUMBER) RETURN varchar2; --- Пользователь Парус контрагента Администартора
  FUNCTION ADMIN_DOV(PIN_COM IN NUMBER, PIN_DATE IN date default sysdate) RETURN varchar2;

  FUNCTION TALON_ISP_USL_1_RN(PIN_DOC IN number) RETURN Number; --- основной исполнитель услуги в талоне
  FUNCTION TALON_ISP_USL_FIO(PIN_DOC IN number, pin_REJ in number) RETURN varchar2; --- ФИО исполнителя услуги в талоне  

END;
/
CREATE OR REPLACE PACKAGE BODY PARUS.SPU_PKG_REP IS

  FUNCTION SPU_AGNLIST_ADDR(PIN_RN IN NUMBER, PIN_FORMAT IN VARCHAR2 DEFAULT 'CPRYTSHBLF', PIN_DELIM IN VARCHAR2 DEFAULT ', ')
    RETURN VARCHAR2 IS
    /* функция возвращает адрес (ОСНОВНОЙ) Получателя платных услуг по формату:
     геогр. понятия.
    C - страна,
    O - код страны,
    A - код ОКАТО страны,
    P - индекс,
    R - регион,
    D - район,
    Y - город,
    U - внутригородская территория,
    T - населенный пункт,
    S - улица,
    V - дополнительная территория,
    W - подчиненный дополнительным территориям
    H - дом,
    B - корпус,
    L - строение,
    F - квартира    
    */
    V_RES VARCHAR2(2000);
  BEGIN
    FOR cur IN (SELECT AD.geografy_rn, ad.post_index, ad.house, ad.building, ad.construction, ad.flat
                  FROM SPU_AGNLIST t, SPU_AGNADDRESS AD
                 WHERE t.RN = PIN_RN
                   AND Ad.prn = t.rn
                   AND AD.Is_Main = 1)
    
     LOOP
      PKG_GEOGRAFY.MAKE_ADDRESS(nRN        => cur.geografy_rn,
                                sFORMAT    => PIN_FORMAT,
                                sPOST      => cur.post_index,
                                sHOUSE     => cur.house,
                                sBLOCK     => cur.construction,
                                sBUILDING  => cur.building,
                                sFLAT      => cur.flat,
                                sADDRESS   => V_RES,
                                sDELIMITER => PIN_DELIM);
    
    END LOOP;
  
    RETURN nvl(V_RES, '');
  
  END; ---кнц SPU_AGNLIST_ADDR

  FUNCTION SPU_TALON_STAFF(PIN_DOC IN NUMBER, PIN_VID IN VARCHAR2 DEFAULT NULL) RETURN SYS_REFCURSOR IS
  
    /*  Функция возвращает Исполнителей талона указанного вида,  по типу, если тип не задан, то всех! 
    PIN_DOC --- RN Талона
    
    TYPE TYP_ISP IS RECORD(
       FM      VARCHAR2(240), --- Фамилия Исполнителя
       IM      VARCHAR2(240), --- Имя Исполнителя
       OT      VARCHAR2(240), --- Отчество Исполнителя
       sVIS    VARCHAR2(240), --- Вид исполнителя 
       Emppost VARCHAR2(240), --- Штатная должность исполнителя
       sPODR  VARCHAR2(240),  --- Штатное подразделение исполнителя
       );
    V_RES_ISP TYP_ISP; --- Запись состава
    CUR_ISP   SYS_REFCURSO; --- Объявдляем курсор
    */
  
    CUR1 SYS_REFCURSOR;
  
  BEGIN
  
    OPEN cur1 FOR
      SELECT DISTINCT a.agnfamilyname, A.AGNFIRSTNAME, A.AGNLASTNAME, tY.Code, DOL.PSDEP_NAME, dep.name
        FROM SPU_TALON_SP    SP,
             SPU_TALON_STAFF t,
             SPU_STAFF_TYPE  TY,
             clnpspfm        PM,
             ins_department  DEP,
             clnpersons      CP,
             agnlist         A,
             clnpsdep        DOL
       WHERE SP.prn = PIN_DOC
         AND sp.rn = t.PRN
         AND t.staff_type = Ty.rn
         AND (PIN_VID IS NULL OR tY.Code = PIN_VID)
         AND T.STAFF_PSPFM = pm.rn
         AND pm.deptrn = DEP.rn
         AND PM.persrn = cP.rn
         AND CP.Pers_Agent = A.rn
         AND PM.Psdeprn = dol.rn
       ORDER BY a.agnfamilyname, A.AGNFIRSTNAME, A.AGNLASTNAME;
    RETURN cur1;
  END; --- кнц SPU_TALON_STAFF

  FUNCTION SPU_USLUG_STAFF(PIN_DOC IN NUMBER, PIN_VID IN VARCHAR2 DEFAULT NULL) RETURN SYS_REFCURSOR IS
  
    /*  Функция возвращает Исполнителей конкретной услуги талона, по типу, если тип не задан, то всех! 
        сортировка по ФИО
    PIN_DOC --- RN услуги талона
    (аналогично функции SPU_TALON_STAFF)
    */
  
    CUR1 SYS_REFCURSOR;
  
  BEGIN
  
    OPEN cur1 FOR
      SELECT a.agnfamilyname, A.AGNFIRSTNAME, A.AGNLASTNAME, tY.Code, DOL.PSDEP_NAME, dep.name
        FROM SPU_TALON_STAFF t, SPU_STAFF_TYPE TY, clnpspfm PM, ins_department DEP, clnpersons CP, agnlist A, clnpsdep DOL
       WHERE t.PRN = PIN_DOC
         AND t.staff_type = Ty.rn
         AND (PIN_VID IS NULL OR tY.Code = PIN_VID)
         AND T.STAFF_PSPFM = pm.rn
         AND pm.deptrn = DEP.rn
         AND PM.persrn = cP.rn
         AND CP.Pers_Agent = A.rn
         AND PM.Psdeprn = dol.rn
       ORDER BY a.agnfamilyname, A.AGNFIRSTNAME, A.AGNLASTNAME;
    RETURN cur1;
  END; --- кнц SPU_USLUG_STAFF   

  function ADMIN_FIO(PIN_COM IN NUMBER, PIN_RES IN number) RETURN varchar2 is
  
    V_RES varchar2(255);
  
  begin
  
    begin
    
      select case pin_RES
               when 0 then --- Инициалы
                A.AGNFAMILYNAME || ' ' || substr(A.AGNFIRSTNAME, 1, 1) || '. ' || substr(A.Agnlastname, 1, 1) || '.'
               when 1 then --- Именительный падеж 
                A.AGNFAMILYNAME || ' ' || A.AGNFIRSTNAME || ' ' || A.Agnlastname
               when 2 then --- Родительный падеж  
                A.AGNFAMILYNAME_FR || ' ' || A.AGNFIRSTNAME_FR || ' ' || A.Agnlastname_FR
               else -- Инициалы (если еще не описанный парметр)
                A.AGNFAMILYNAME || ' ' || substr(A.AGNFIRSTNAME, 1, 1) || '. ' || substr(A.Agnlastname, 1, 1) || '.'
             end case
        into V_RES
        from docs_props_vals S, compverlist V1, docs_props SV, compverlist V2, agnlist A
       where S.STR_VALUE = user
         and S.UNITCODE = 'AGNLIST'
         and V1.Version = S.Version
         and V1.Unitcode = S.Unitcode
         and V1.Company = PIN_COM
         and SV.rn = S.Docs_Prop_Rn
         and SV.Code = 'PARUS_USER'
         and SV.Version = V2.Version
         and V2.UNITCODE = 'DocsProperties'
         and V2.Company = V1.Company
         and A.rn = S.Unit_Rn
         and A.Version = V1.Version;
    
    exception
      when no_data_found then
        V_RES := null;
      
    end;
    return V_RES;
  
  end;

  function ADMIN_DOL(PIN_COM IN NUMBER, PIN_RES IN number default 0) RETURN varchar2 is
  
    V_RES varchar2(255);
  
  begin
  
    begin
    
      select case PIN_RES
               when 1 then
                A.Emppost ------ Именительный падеж 
               when 2 then
                A.Emppost_From ---- Родительный падеж
               else
                A.Emppost
             end
        into V_RES
        from docs_props_vals S, compverlist V1, docs_props SV, compverlist V2, agnlist A
       where S.STR_VALUE = user
         and S.UNITCODE = 'AGNLIST'
         and V1.Version = S.Version
         and V1.Unitcode = S.Unitcode
         and V1.Company = PIN_COM
         and SV.rn = S.Docs_Prop_Rn
         and SV.Code = 'PARUS_USER'
         and SV.Version = V2.Version
         and V2.UNITCODE = 'DocsProperties'
         and V2.Company = V1.Company
         and A.rn = S.Unit_Rn
         and A.Version = V1.Version;
    
    exception
      when no_data_found then
        V_RES := null;
      
    end;
    return V_RES;
  
  end;

  FUNCTION ADMIN_ABBR(PIN_COM IN NUMBER) RETURN varchar2 is
  
    V_RES varchar2(255);
  
  begin
  
    begin
    
      select A.AGNABBR
        into V_RES
        from docs_props_vals S, compverlist V1, docs_props SV, compverlist V2, agnlist A
       where S.STR_VALUE = user
         and S.UNITCODE = 'AGNLIST'
         and V1.Version = S.Version
         and V1.Unitcode = S.Unitcode
         and V1.Company = PIN_COM
         and SV.rn = S.Docs_Prop_Rn
         and SV.Code = 'PARUS_USER'
         and SV.Version = V2.Version
         and V2.UNITCODE = 'DocsProperties'
         and V2.Company = V1.Company
         and A.rn = S.Unit_Rn
         and A.Version = V1.Version;
    
    exception
      when no_data_found then
        V_RES := null;
      
    end;
    return V_RES;
  
  end;

  FUNCTION ADMIN_USER(PIN_COM IN NUMBER) RETURN varchar2 is
  
    V_RES varchar2(255);
  
  begin
  
    begin
    
      select S.STR_VALUE
        into V_RES
        from docs_props_vals S, compverlist V1, docs_props SV, compverlist V2
       where S.STR_VALUE = user
         and S.UNITCODE = 'AGNLIST'
         and V1.Version = S.Version
         and V1.Unitcode = S.Unitcode
         and V1.Company = PIN_COM
         and SV.rn = S.Docs_Prop_Rn
         and SV.Code = 'PARUS_USER'
         and SV.Version = V2.Version
         and V2.UNITCODE = 'DocsProperties'
         and V2.Company = V1.Company;
    
    exception
      when no_data_found then
        V_RES := null;
      
    end;
    return V_RES;
  
  end;

  FUNCTION ADMIN_DOV(PIN_COM IN NUMBER, PIN_DATE IN date default sysdate) RETURN varchar2 is
  
    V_RES varchar2(255);
  
  begin
    begin
      select V.STRVALUE
        into V_RES
        from CONSTLST T
        join CONSTVAL V
          on v.prn = T.RN
       where T.NAME = SPU_PKG_REP.ADMIN_USER(PIN_COM)
         and T.Company = PIN_COM
         and sysdate between V.Datefrom and nvl(V.Dateto, sysdate);
    
    exception
      when no_data_found then
        V_RES := null;
      
    end;
    return V_RES;
  
  end;

  FUNCTION TALON_ISP_USL_1_RN(PIN_DOC IN number) RETURN number is
  
    V_RES number;
  Begin
    Begin
      select t.rn
        into V_RES
        from SPU_TALON_STAFF t
        join SPU_STAFF_TYPE ST
          on st.rn = t.staff_type
      
       where t.PRN = PIN_DOC
            
         and ST.rang =
             (select min(St1.rang) from SPU_TALON_STAFF t1 join SPU_STAFF_TYPE ST1 on st1.rn = t1.staff_type where t1.PRN = t.prn)
             and rownum = 1;
    
    exception
      when No_data_found then
        return null;
      
    end;
  
    return V_RES;
  
  end;

  FUNCTION TALON_ISP_USL_FIO(PIN_DOC IN number, pin_REJ in number) RETURN varchar2 is
    --- ФИО исполнителя услуги в талоне  
  
    V_RES varchar2(255);
  begin
    begin
      select case pin_REJ
               when 0 then
                initcap(A.AGNFAMILYNAME) || ' ' || upper(substr(A.AGNFIRSTNAME, 1, 1)) || '. ' || upper(substr(A.AGNLASTNAME, 1, 1)) || '. '
               else
                ''
             end
        into V_RES
        from SPU_TALON_STAFF SF
        join clnpspfm PM
          on pm.rn = sf.staff_pspfm
        join clnpersons cp
          on cp.rn = pm.persrn
        join agnlist A
          on a.rn = cp.pers_agent
       where sf.rn = pin_doc;
    exception
      when No_data_found then
        return null;
      
    end;
  
    return V_RES;
  
  end;

END; --- КНЦ пакета
/
