CREATE OR REPLACE PACKAGE PARUS.UDO_PKG_REP IS

  FUNCTION RUK_AGENT_CODE(PIN_NAGN IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2;
  FUNCTION RUK_AGENT_FIO(PIN_NAGN IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2;
  FUNCTION RUK_AGENT_CODE(PIN_COM IN NUMBER, PIN_SAGN IN VARCHAR2, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2;
  FUNCTION RUK_AGENT_FIO(PIN_COM IN NUMBER, PIN_SAGN IN VARCHAR2, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2;

  FUNCTION RUK_AGENT_RN(PIN_NAGN IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN NUMBER;
  PROCEDURE AGENT_ATTR(PIN_COM  IN NUMBER,
                       PIN_REJ  IN NUMBER,
                       PIN_SAGN IN VARCHAR2,
                       OUT_FIO  OUT VARCHAR2,
                       OUT_DOL  OUT VARCHAR2,
                       OUT_TEL  OUT VARCHAR2);
  PROCEDURE AGENT_ATTR(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_SAGN IN VARCHAR2, OUT_FIO OUT VARCHAR2);
  PROCEDURE AGENT_ATTR(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_SAGN IN VARCHAR2, OUT_FIO OUT VARCHAR2, OUT_DOL OUT VARCHAR2);
  PROCEDURE AGENT_ATTR(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_NAGN IN NUMBER, OUT_FIO OUT VARCHAR2, OUT_DOL OUT VARCHAR2);

  FUNCTION AGENT_FIO(PIN_NAGN IN NUMBER, PIN_PADEJ in number default 0) RETURN VARCHAR2;
  ---- По коду контрагента возвращаем его реквизит заданный паремтром PIN_VID
  FUNCTION AGENT_FIO(PIN_SAGN IN VARCHAR2, PIN_COM IN NUMBER, PIN_VID IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION AGENT_FIO(PIN_NAGN IN NUMBER, PIN_VID IN VARCHAR2) RETURN VARCHAR2;

  --- По пользователю USER возвращает мнемокод контрагента к которому у которого совйство 
  ---- PARUS_USER  = USER
  FUNCTION USER_AGENT(PIN_COM IN NUMBER) RETURN VARCHAR2;
  FUNCTION USER_AGENT(PIN_COM IN NUMBER, pin_REJ in number) RETURN VARCHAR2;

  --- Значения свойства по его мнемокоду, коду раздела, RN документа и RN организации или версии
  PROCEDURE DPV(PIN_COM  IN NUMBER,
                PIN_REJ  IN NUMBER,
                PIN_DOC  IN NUMBER,
                PIN_CODE IN VARCHAR2,
                PIN_UNI  IN VARCHAR2,
                OUT_STR  OUT VARCHAR2,
                OUT_NUM  OUT NUMBER,
                OUT_DAT  OUT DATE,
                OUT_SRC  OUT NUMBER);
  --- Строковое значение свойства                
  FUNCTION DOCS_PROPS_VALS_S(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_DOC IN NUMBER, PIN_CODE IN VARCHAR2, PIN_UNI IN VARCHAR2)
    RETURN VARCHAR2;
  --- Цифровое значение свойства  
  FUNCTION DOCS_PROPS_VALS_N(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_DOC IN NUMBER, PIN_CODE IN VARCHAR2, PIN_UNI IN VARCHAR2)
    RETURN NUMBER;
  --- Датское значение свойства  
  FUNCTION DOCS_PROPS_VALS_D(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_DOC IN NUMBER, PIN_CODE IN VARCHAR2, PIN_UNI IN VARCHAR2)
    RETURN DATE;
  --- Ссылка на идентификатор источника значения свойства (если значение задано через справочник или доп словарь)
  FUNCTION DOCS_PROPS_VALS_SRC(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_DOC IN NUMBER, PIN_CODE IN VARCHAR2, PIN_UNI IN VARCHAR2)
    RETURN NUMBER;

  --- Примечание дополнительного словаря  по его значению
  FUNCTION EXTRA_DICTS_VALS_S(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_ZN IN VARCHAR2, PIN_CODE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION EXTRA_DICTS_VALS_N(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_ZN IN NUMBER, PIN_CODE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION EXTRA_DICTS_VALS_D(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_ZN IN DATE, PIN_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION COMPANY_AGNLIST_NAME(PIN_COM IN NUMBER, PIN_REJ IN NUMBER) RETURN VARCHAR2;
  FUNCTION COMPANY_AGNLIST_OKPO(PIN_COM IN NUMBER, PIN_REJ IN NUMBER) RETURN VARCHAR2;
  FUNCTION COMPANY_RUK_RN(PIN_COM IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN NUMBER;
  FUNCTION COMPANY_RUK_FIO(PIN_COM IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER, PIN_PADEJ in number default 0) RETURN VARCHAR2;
  --- Если у любой из номенклатур задан код СЛП, то 1 иначе 0
  FUNCTION NOMEN_IS_DRUG(PIN_COM IN NUMBER, NOMEN_RN IN NUMBER) RETURN NUMBER;
  FUNCTION NOMEN_IS_PKU(PIN_COM IN NUMBER, NOMEN_RN IN NUMBER) RETURN NUMBER;
  FUNCTION NOMEN_IS_JNVLP(PIN_COM IN NUMBER, PIN_NOMEN IN NUMBER, PIN_MODIF IN NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION NOMEN_Q_UPACK(PIN_NOM_RN IN NUMBER) RETURN NUMBER;
  --- Количество в упаковке по RN упаковки модификаци
  FUNCTION MODIF_Q_UPACK(PIN_NOMNMODIFPACK IN NUMBER) RETURN NUMBER;
  FUNCTION NOMEN_NAME_UPACK(PIN_NOM_RN IN NUMBER) RETURN varchar2;
  ---- Определение значения констанат
  FUNCTION CONST_VAL_S(PIN_COM IN NUMBER, PIN_CODE IN VARCHAR2, PIN_DATE IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2;
  FUNCTION CONST_VAL_N(PIN_COM IN NUMBER, PIN_CODE IN VARCHAR2, PIN_DATE IN DATE, PIN_REJ IN NUMBER) RETURN NUMBER;
  FUNCTION CONST_VAL_D(PIN_COM IN NUMBER, PIN_CODE IN VARCHAR2, PIN_DATE IN DATE, PIN_REJ IN NUMBER) RETURN DATE;
  PROCEDURE CONST_VAL(PIN_COM   IN NUMBER,
                      PIN_CODE  IN VARCHAR2,
                      PIN_DATE  IN DATE,
                      PIN_REJ   IN NUMBER,
                      OUT_RES_S OUT VARCHAR2,
                      OUT_RES_N OUT NUMBER,
                      OUT_RES_D OUT DATE);
  FUNCTION GR_LS(PIN_COM IN NUMBER, PIN_NOM IN NUMBER, PIN_VID_RES IN VARCHAR2, PIN_D1 in date , PIN_d2 in date ,PIN_NO_RN in number default null, PIN_VID_MI in number default null) RETURN VARCHAR2;
  
  --- Подсчет - сколько раз номенклатура входит в Группы учета ЛС на указанном периоде
  FUNCTION NOMEN_IN_GR_LS(PIN_COM IN NUMBER, PIN_NOM IN NUMBER, PIN_CODE_GR IN VARCHAR2, PIN_D1 in date , PIN_D2 in date,PIN_NO_RN in number default null, PIN_VID_MI in number default null) RETURN NUMBER;
  --- Постоянно действующие комиссии  
  FUNCTION KOMIS_ZAG(PIN_COM IN NUMBER, PIN_NAME IN VARCHAR2) RETURN SYS_REFCURSOR;
  FUNCTION KOMIS_SOST(PIN_DOC IN NUMBER, PIN_DATE IN DATE) RETURN SYS_REFCURSOR;

  FUNCTION DEPT_NAME_BY_CODE(PIN_COM IN NUMBER, PIN_CODE IN VARCHAR2, PIN_REJ IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION MONTH_NAME(PIN_N IN NUMBER, PIN_REJ IN NUMBER) RETURN VARCHAR2;
  FUNCTION MONTH_NAME(PIN_D IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2;

  FUNCTION KVARTAL_NMB(PIN_N IN number) RETURN VARCHAR2; --- Номер квартала по номеру месяца   
  FUNCTION KVARTAL_NMB(PIN_D IN DATE) RETURN VARCHAR2; --- Номер квартала по дате

  --- Остаток на дату по строке товарного запаса
  FUNCTION OST_GY(PIN_COM IN NUMBER, PIN_GY IN NUMBER, PIN_DATE IN DATE, PIN_REJ IN VARCHAR2) RETURN NUMBER;

  --- Остаток на дату по модификации номенклатуры и выбранным складам
  FUNCTION OST_NOMMODIF(PIN_COM IN NUMBER, PIN_NMRN IN NUMBER, PIN_DATE IN DATE, PIN_STORE IN VARCHAR2, PIN_REJ IN VARCHAR2)
    RETURN NUMBER;
 ---Остаток на дату по модификации по одному складк
  FUNCTION OST_NOMMODIF(PIN_COM IN NUMBER, PIN_NMRN IN NUMBER, PIN_DATE IN DATE, PIN_STORE IN number, PIN_REJ IN VARCHAR2)
    RETURN NUMBER;   
    

  FUNCTION VID_TMC_KOSGU(PIN_KOSGU IN VARCHAR2) RETURN NUMBER;
  FUNCTION NDS_RATE(PIN_TAX_GR IN VARCHAR2, PIN_COMPANY IN NUMBER, PIN_DATE IN DATE DEFAULT SYSDATE) RETURN NUMBER;
  FUNCTION NDS_RATE(PIN_TAX_GR IN NUMBER, PIN_COMPANY IN NUMBER, PIN_DATE IN DATE DEFAULT SYSDATE) RETURN NUMBER;
  FUNCTION STOREOPERJOURN_CONTRAGENT(PIN_DOC IN NUMBER, PIN_UNI IN VARCHAR2, PIN_OUT IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION STOREOPERJOURN_MOL(PIN_DOC IN NUMBER, PIN_UNI IN VARCHAR2, PIN_OUT IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION ACCOUNTING_ENTRY(PIN_DOC IN NUMBER, PIN_IN_NOM IN NUMBER, PIN_UNI_NOM in Varchar2) RETURN SYS_REFCURSOR;

  FUNCTION PARUS_USER_AGNABBR(PIN_COM IN NUMBER, PIN_SV_CODE IN VARCHAR2 DEFAULT 'PARUS_USER') RETURN VARCHAR2;
  PROCEDURE SOTR_ATTR(PIN_DOC      IN NUMBER,
                      PIN_COM      IN NUMBER,
                      PIN_DATE     IN DATE,
                      OUT_DOL      OUT VARCHAR2,
                      OUT_DEP_CODE OUT VARCHAR2,
                      OUT_DEP_NAME OUT VARCHAR2);
  --- даляет из конца строки PIN_STR набор символов PIN_DEL_SYMB  -  PIN_NUMb раз                      
  FUNCTION DEL_LAST_CHAR(PIN_STR IN VARCHAR2, PIN_DEL_SYMB IN VARCHAR2, PIN_NUMB IN NUMBER) RETURN VARCHAR2;
  FUNCTION FRAC_PART_NUMBER(PIN_NUMBER IN NUMBER, PIN_TR_1 IN NUMBER, PIN_TR_2 IN NUMBER) RETURN VARCHAR2;

END;
/
CREATE OR REPLACE PACKAGE BODY PARUS.UDO_PKG_REP IS

  FUNCTION RUK_AGENT_RN(PIN_NAGN IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN NUMBER AS

    V_RES PARUS.AGNLIST.RN%TYPE;

  BEGIN
    ---PIN_REJ 0-- Главный бухгалтер, 1- Руководитель
    BEGIN
      SELECT GB.AGENT
        INTO V_RES
        FROM PARUS.AGNMANAGE GB
       WHERE GB.PRN = PIN_NAGN
         AND GB.POSITION = PIN_REJ
         AND GB.REG_DATE <= PIN_DAT
         AND GB.REG_DATE = (SELECT MAX(TT.REG_DATE)
                              FROM PARUS.AGNMANAGE TT
                             WHERE TT.PRN = GB.PRN
                               AND TT.POSITION = GB.POSITION
                               AND TT.REG_DATE <= PIN_DAT);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := NULL;

    END;
    RETURN V_RES;

  END RUK_AGENT_RN;

  FUNCTION AGENT_FIO(PIN_NAGN IN NUMBER, PIN_PADEJ in number default 0) RETURN VARCHAR2 AS

    V_RES VARCHAR2(2000);

  BEGIN
    BEGIN

      SELECT
           case PIN_PADEJ
              when 0 then --- Именительный сокращенный

             CASE
               WHEN MOL.AGNFAMILYNAME IS NULL THEN
                MOL.AGNABBR
               ELSE
                MOL.AGNFAMILYNAME || NVL2(MOL.AGNFIRSTNAME, ' ' || SUBSTR(MOL.AGNFIRSTNAME, 1, 1) || '.', '') ||
                NVL2(MOL.AGNLASTNAME, ' ' || SUBSTR(MOL.AGNLASTNAME, 1, 1) || '.', '')
             END

              when -1 then --- Именительный сокращенный Иимя, Отчество, Фамилия

             CASE
               WHEN MOL.AGNFAMILYNAME IS NULL THEN
                MOL.AGNABBR
               ELSE
                 NVL2(MOL.AGNFIRSTNAME, ' ' || SUBSTR(MOL.AGNFIRSTNAME, 1, 1) || '.', '') ||
                NVL2(MOL.AGNLASTNAME, ' ' || SUBSTR(MOL.AGNLASTNAME, 1, 1) || '.', '')||' '||MOL.AGNFAMILYNAME
             END


             when 10 then --- Именительный полный

             CASE
               WHEN MOL.AGNFAMILYNAME IS NULL THEN
                MOL.AGNABBR
               ELSE
                MOL.AGNFAMILYNAME || ' ' ||MOL.AGNFIRSTNAME ||' '||MOL.AGNLASTNAME
             END
             When 1 then  --- Родительный  фамилия физического лица (от кого)

             CASE
               WHEN MOL.AGNFAMILYNAME_FR IS NULL THEN
                MOL.AGNABBR
               ELSE
                MOL.AGNFAMILYNAME_FR || ' ' ||MOL.AGNFIRSTNAME_FR ||' '||MOL.AGNLASTNAME_FR
             END

             When 2 then  --- Дательный  - имя физического лица (кому)

             CASE
               WHEN MOL.AGNFAMILYNAME_TO IS NULL THEN
                MOL.AGNABBR
               ELSE
                MOL.AGNFAMILYNAME_TO || ' ' ||MOL.AGNFIRSTNAME_TO ||' '||MOL.AGNLASTNAME_TO
             END

             When 3 then  ---  Винительный

             CASE
               WHEN MOL.AGNFAMILYNAME_AC IS NULL THEN
                MOL.AGNABBR
               ELSE
                MOL.AGNFAMILYNAME_AC || ' ' ||MOL.AGNFIRSTNAME_AC ||' '||MOL.AGNLASTNAME_AC
             END

             when 30 then
             CASE
               WHEN MOL.AGNFAMILYNAME_AC IS NULL THEN
                MOL.AGNABBR
               ELSE
                MOL.AGNFAMILYNAME_AC || ' ' ||substr(MOL.AGNFIRSTNAME_AC,1,1) ||'. '||substr(MOL.AGNLASTNAME_AC,1,1)||'. '
             END

             When 4 then  ---  творительный падеж

             CASE
               WHEN MOL.AGNFAMILYNAME_ABL IS NULL THEN
                MOL.AGNABBR
               ELSE
                MOL.AGNFAMILYNAME_ABL || ' ' ||MOL.AGNFIRSTNAME_ABL ||' '||MOL.AGNLASTNAME_ABL
             END


          ELSE
             MOL.AGNABBR --- Неправильно задан паремтр Падеж
          end


        INTO V_RES
        FROM AGNLIST MOL
       WHERE MOL.RN = PIN_NAGN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := '';
    END;

    RETURN V_RES;

  END AGENT_FIO;

  FUNCTION AGENT_FIO(PIN_SAGN IN VARCHAR2, PIN_COM IN NUMBER, PIN_VID IN VARCHAR2) RETURN VARCHAR2 AS
    --- Мнемокод контрагента, компания, вид выводимой информации
    V_RES VARCHAR2(2000) := '';

    V_FIELD VARCHAR2(2000) := CASE PIN_VID
                                WHEN 'AGNNAME' THEN
                                 't.agnname'
                                WHEN 'FULL_NAME' THEN
                                 'T.AGNFAMILYNAME || CASE WHEN T.AGNFIRSTNAME IS NOT NULL THEN '' '' || T.AGNFIRSTNAME ELSE  '''' END ||CASE WHEN T.AGNLASTNAME IS NOT NULL THEN  '' '' || T.AGNLASTNAME ELSE '''' END'
                                WHEN 'FIO' THEN
                                 'T.AGNFAMILYNAME || CASE WHEN T.AGNFIRSTNAME IS NOT NULL THEN '' '' || substr(T.AGNFIRSTNAME,1,1)||''.'' ELSE  '''' END ||
                                                      CASE WHEN T.AGNLASTNAME IS NOT NULL THEN  '' '' || substr(T.AGNLASTNAME,1,1)||''.'' ELSE '''' END'
                                WHEN 'EMPPOST' THEN
                                 'T.emppost'
                                ELSE
                                 'T.AGNABBR'
                              END;
  BEGIN

    BEGIN
      EXECUTE IMMEDIATE 'SELECT ' || V_FIELD ||
                        ' FROM AGNLIST t, Compverlist V WHERE t.AGNABBR = :AGN AND T.Version = V.Version  AND V.COMPANY = :COMP AND V.Unitcode = ' ||
                        '''AGNLIST'''
        INTO V_RES
        USING PIN_SAGN, PIN_COM;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := '';
    END;

    RETURN V_RES;

  END AGENT_FIO;

  FUNCTION AGENT_FIO(PIN_NAGN IN NUMBER, PIN_VID IN VARCHAR2) RETURN VARCHAR2 is

    --- RN контрагента, компания, вид выводимой информации
    V_RES VARCHAR2(2000) := '';

    V_FIELD VARCHAR2(2000) := CASE PIN_VID
                                WHEN 'AGNNAME' THEN
                                 't.agnname'
                                WHEN 'FULL_NAME' THEN
                                 'T.AGNFAMILYNAME || CASE WHEN T.AGNFIRSTNAME IS NOT NULL THEN '' '' || T.AGNFIRSTNAME ELSE  '''' END ||CASE WHEN T.AGNLASTNAME IS NOT NULL THEN  '' '' || T.AGNLASTNAME ELSE '''' END'
                                WHEN 'FIO' THEN
                                 'T.AGNFAMILYNAME || CASE WHEN T.AGNFIRSTNAME IS NOT NULL THEN '' '' || substr(T.AGNFIRSTNAME,1,1)||''.'' ELSE  '''' END ||
                                                      CASE WHEN T.AGNLASTNAME IS NOT NULL THEN  '' '' || substr(T.AGNLASTNAME,1,1)||''.'' ELSE '''' END'
                                WHEN 'EMPPOST' THEN
                                 'T.emppost'
                                ELSE
                                 'T.AGNABBR'
                              END;
  BEGIN

    BEGIN
      EXECUTE IMMEDIATE 'SELECT ' || V_FIELD || ' FROM AGNLIST t WHERE t.rn = :AGN '
        INTO V_RES
        USING PIN_NAGN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := '';
    END;

    RETURN V_RES;

  END AGENT_FIO;

  FUNCTION RUK_AGENT_CODE(PIN_NAGN IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2 AS

    V_RES PARUS.AGNLIST.AGNABBR%TYPE;

  BEGIN

    /* PIN_REJ  (0-гл. бухгалтер, 1-руководитель)
       PIN_nAGN -- RN организации у которой ищем руководство
    */
    BEGIN

      SELECT M.AGNABBR
        INTO V_RES
        FROM PARUS.AGNMANAGE GB, PARUS.AGNLIST M
       WHERE GB.PRN = PIN_NAGN
         AND GB.AGENT = M.RN
         AND GB.POSITION = PIN_REJ
         AND GB.REG_DATE <= PIN_DAT
         AND GB.REG_DATE = (SELECT MAX(TT.REG_DATE)
                              FROM PARUS.AGNMANAGE TT
                             WHERE TT.PRN = GB.PRN
                               AND TT.POSITION = GB.POSITION
                               AND TT.REG_DATE <= PIN_DAT);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := NULL;

    END;
    RETURN V_RES;

  END RUK_AGENT_CODE;

  FUNCTION RUK_AGENT_FIO(PIN_NAGN IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2 AS
    V_RES VARCHAR2(520);
  BEGIN

    /* PIN_REJ  (0-гл. бухгалтер, 1-руководитель)
       PIN_nAGN -- RN организации у которой ищем руководство
    */
    BEGIN

      SELECT M.AGNFAMILYNAME || NVL2(M.AGNFIRSTNAME, ' ' || SUBSTR(M.AGNFIRSTNAME, 1, 1) || '.', '') ||
             NVL2(M.AGNLASTNAME, ' ' || SUBSTR(M.AGNLASTNAME, 1, 1) || '.', '')
        INTO V_RES
        FROM PARUS.AGNMANAGE GB, PARUS.AGNLIST M
       WHERE GB.PRN = PIN_NAGN
         AND GB.AGENT = M.RN
         AND GB.POSITION = PIN_REJ
         AND GB.REG_DATE <= PIN_DAT
         AND GB.REG_DATE = (SELECT MAX(TT.REG_DATE)
                              FROM PARUS.AGNMANAGE TT
                             WHERE TT.PRN = GB.PRN
                               AND TT.POSITION = PIN_REJ
                               AND TT.REG_DATE <= PIN_DAT);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := NULL;

    END;
    RETURN V_RES;

  END RUK_AGENT_FIO;

  FUNCTION RUK_AGENT_CODE(PIN_COM IN NUMBER, PIN_SAGN IN VARCHAR2, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2 AS

    V_RES PARUS.AGNLIST.AGNABBR%TYPE;
  BEGIN

    /* PIN_REJ  (0-гл. бухгалтер, 1-руководитель)  */
    BEGIN

      SELECT M.AGNABBR
        INTO V_RES
        FROM PARUS.AGNLIST ORG, PARUS.COMPVERLIST V, PARUS.AGNMANAGE GB, PARUS.AGNLIST M
       WHERE ORG.AGNABBR = PIN_SAGN
         AND ORG.VERSION = V.VERSION
         AND V.COMPANY = PIN_COM
         AND GB.PRN = ORG.RN
         AND GB.AGENT = M.RN
         AND GB.POSITION = PIN_REJ
         AND GB.REG_DATE <= PIN_DAT
         AND GB.REG_DATE = (SELECT MAX(TT.REG_DATE)
                              FROM PARUS.AGNMANAGE TT
                             WHERE TT.PRN = GB.PRN
                               AND TT.POSITION = GB.POSITION
                               AND TT.REG_DATE <= PIN_DAT);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := NULL;

    END;
    RETURN V_RES;

  END RUK_AGENT_CODE;

  FUNCTION RUK_AGENT_FIO(PIN_COM IN NUMBER, PIN_SAGN IN VARCHAR2, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2 AS
    /* PIN_REJ  (0-гл. бухгалтер, 1-руководитель)  */
    V_RES VARCHAR2(520);
  BEGIN
    BEGIN
      SELECT M.AGNFAMILYNAME || NVL2(M.AGNFIRSTNAME, ' ' || SUBSTR(M.AGNFIRSTNAME, 1, 1) || '.', '') ||
             NVL2(M.AGNLASTNAME, ' ' || SUBSTR(M.AGNLASTNAME, 1, 1) || '.', '')
        INTO V_RES
        FROM PARUS.AGNLIST ORG, PARUS.COMPVERLIST V, PARUS.AGNMANAGE GB, PARUS.AGNLIST M
       WHERE ORG.AGNABBR = PIN_SAGN
         AND ORG.VERSION = V.VERSION
         AND V.COMPANY = PIN_COM
         AND GB.PRN = ORG.RN
         AND GB.AGENT = M.RN
         AND GB.POSITION = PIN_REJ
         AND GB.REG_DATE <= PIN_DAT
         AND GB.REG_DATE = (SELECT MAX(TT.REG_DATE)
                              FROM PARUS.AGNMANAGE TT
                             WHERE TT.PRN = GB.PRN
                               AND TT.POSITION = GB.POSITION
                               AND TT.REG_DATE <= PIN_DAT);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := NULL;

    END;
    RETURN V_RES;

  END RUK_AGENT_FIO;

  FUNCTION USER_AGENT(PIN_COM IN NUMBER) RETURN VARCHAR2 AS
    V_RES AGNLIST.AGNABBR%TYPE;
  BEGIN

    BEGIN
      SELECT AG.AGNABBR
        INTO V_RES
        FROM DOCS_PROPS DP, COMPVERLIST V1, DOCS_PROPS_VALS SV, COMPVERLIST V2, AGNLIST AG
       WHERE DP.CODE = 'PARUS_USER'
         AND DP.VERSION = V1.VERSION
         AND V1.COMPANY = PIN_COM
         AND V1.UNITCODE = 'DocsProperties'
         AND SV.DOCS_PROP_RN = DP.RN
         AND SV.STR_VALUE = USER
         AND SV.VERSION = V2.VERSION
         AND V2.COMPANY = V1.COMPANY
         AND V2.UNITCODE = 'AGNLIST'
         AND AG.RN = SV.UNIT_RN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := NULL;
    END;
    RETURN V_RES;
  END;


  FUNCTION USER_AGENT(PIN_COM IN NUMBER, PIN_REJ in number) RETURN VARCHAR2 AS
    V_RES VARCHAR2(2000);
  BEGIN

    BEGIN
      SELECT case PIN_REJ when 0 then AG.AGNABBR
      when 1 then AG.AGNFAMILYNAME||' '||AG.AGNFIRSTNAME||' '||AG.AGNLASTNAME
      when 2 then AG.AGNFAMILYNAME||' '||SUBSTR(AG.AGNFIRSTNAME,1,1)||'. '||SUBSTR(AG.AGNLASTNAME,1,1)||'.'
      Else AG.AGNNAME
        end
        INTO V_RES
        FROM DOCS_PROPS DP, COMPVERLIST V1, DOCS_PROPS_VALS SV,  AGNLIST AG
       WHERE DP.CODE = 'PARUS_USER'
         AND DP.VERSION = V1.VERSION
         AND V1.COMPANY = PIN_COM
         AND V1.UNITCODE = 'DocsProperties'
         AND SV.DOCS_PROP_RN = DP.RN
         AND SV.STR_VALUE = USER
         AND AG.RN = SV.UNIT_RN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := NULL;
    END;
    RETURN V_RES;
  END;

  PROCEDURE AGENT_ATTR(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_SAGN IN VARCHAR2, OUT_FIO OUT VARCHAR2) AS
    V_DOL VARCHAR2(180);
    V_TEL VARCHAR2(80);

  BEGIN
    AGENT_ATTR(PIN_COM, PIN_REJ, PIN_SAGN, OUT_FIO, V_DOL, V_TEL);
  END AGENT_ATTR;

  PROCEDURE AGENT_ATTR(PIN_COM  IN NUMBER,
                       PIN_REJ  IN NUMBER,
                       PIN_SAGN IN VARCHAR2,
                       OUT_FIO  OUT VARCHAR2,
                       OUT_DOL  OUT VARCHAR2,
                       OUT_TEL  OUT VARCHAR2) AS

  BEGIN

    IF PIN_REJ = 1 THEN
      --- Для контрагента SAGENT Выводим Фамилия И.О. Должность, Телефон из вкладки ФИЗ лицо контрагента
      BEGIN
        SELECT TRIM(A.AGNFAMILYNAME || ' ' || NVL2(A.AGNFIRSTNAME, SUBSTR(A.AGNFIRSTNAME, 1, 1) || '.', '') ||
                    NVL2(A.AGNLASTNAME, SUBSTR(A.AGNLASTNAME, 1, 1) || '.', '')),
               A.EMPPOST,
               A.PHONE
          INTO OUT_FIO, OUT_DOL, OUT_TEL
          FROM PARUS.AGNLIST A, PARUS.COMPVERLIST V
         WHERE A.AGNABBR = PIN_SAGN
           AND A.VERSION = V.VERSION
           AND V.COMPANY = PIN_COM
           AND V.UNITCODE = 'AGNLIST';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    ELSIF PIN_REJ = 10 THEN
      --- --- Для контрагента SAGENT Выводим  ПОЛНОЕ ФИО , Должность, Телефон из вкладки ФИЗ лицо контрагента
      BEGIN
        SELECT TRIM(A.AGNFAMILYNAME || ' ' || NVL(A.AGNFIRSTNAME, '') || ' ' || NVL(A.AGNLASTNAME, '')), A.EMPPOST, A.PHONE
          INTO OUT_FIO, OUT_DOL, OUT_TEL
          FROM PARUS.AGNLIST A, PARUS.COMPVERLIST V
         WHERE A.AGNABBR = PIN_SAGN
           AND A.VERSION = V.VERSION
           AND V.COMPANY = PIN_COM
           AND V.UNITCODE = 'AGNLIST';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

    ELSIF PIN_REJ = 2 THEN
      --- --- Для контрагента SAGENT Выводим  Фамилия Имя Отчество Должность, Телефон из вкладки ФИЗ лицо контрагента
      BEGIN
        SELECT TRIM(A.AGNFAMILYNAME || ' ' || NVL2(A.AGNFIRSTNAME, SUBSTR(A.AGNFIRSTNAME, 1, 1) || '.', '') ||
                    NVL2(A.AGNLASTNAME, SUBSTR(A.AGNLASTNAME, 1, 1) || '.', '')),
               A.EMPPOST,
               A.PHONE
          INTO OUT_FIO, OUT_DOL, OUT_TEL
          FROM PARUS.AGNLIST A, PARUS.COMPVERLIST V
         WHERE A.AGNABBR = PIN_SAGN
           AND A.VERSION = V.VERSION
           AND V.COMPANY = PIN_COM
           AND V.UNITCODE = 'AGNLIST';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    ELSIF PIN_REJ = 3 THEN
      NULL;

    END IF;

  END AGENT_ATTR;

  PROCEDURE AGENT_ATTR(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_SAGN IN VARCHAR2, OUT_FIO OUT VARCHAR2, OUT_DOL OUT VARCHAR2) AS
    V_TEL VARCHAR2(80);

  BEGIN
    AGENT_ATTR(PIN_COM, PIN_REJ, PIN_SAGN, OUT_FIO, OUT_DOL, V_TEL);
  END AGENT_ATTR;

  PROCEDURE AGENT_ATTR(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_NAGN IN NUMBER, OUT_FIO OUT VARCHAR2, OUT_DOL OUT VARCHAR2) AS

    V_AGNABBR AGNLIST.AGNABBR%TYPE;

  BEGIN
    BEGIN
      SELECT AG.AGNABBR INTO V_AGNABBR FROM AGNLIST AG WHERE AG.RN = PIN_NAGN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_EXCEPTION(PIN_REJ, 'Контрагент с RN ' || PIN_NAGN || ' не найден');
    END;

    UDO_PKG_REP.AGENT_ATTR(PIN_COM, PIN_REJ, V_AGNABBR, OUT_FIO, OUT_DOL);

  END;

  /* Процедура возвращает все три поля таблицы значения свойств  */
  PROCEDURE DPV(PIN_COM  IN NUMBER, ---Организация
                PIN_REJ  IN NUMBER, ---Режим Если  = 1, то сообщение при отсутсвии свойства с кодом PIN_DOC не выводится
                PIN_DOC  IN NUMBER, -- RN документа
                PIN_CODE IN VARCHAR2, -- Код свойства
                PIN_UNI  IN VARCHAR2, -- Код раздела документта
                OUT_STR  OUT VARCHAR2, --- Значениес типом строка
                OUT_NUM  OUT NUMBER, -- Значение с типом Число
                OUT_DAT  OUT DATE, -- Хначение с типом Дата
                OUT_SRC  OUT NUMBER --- Ссылка на справочник (SOURCE or SOURCE_EXT)
                ) AS
    --- Значение с типом дата

    V_SV_RN PARUS.DOCS_PROPS.RN%TYPE;
  BEGIN
    ---- Найдем RN  свойства
    BEGIN
      SELECT SV.RN
        INTO V_SV_RN
        FROM PARUS.DOCS_PROPS SV, PARUS.COMPVERLIST V
       WHERE SV.CODE = PIN_CODE
         AND V.VERSION = SV.VERSION
         AND V.COMPANY = PIN_COM
         AND V.UNITCODE = 'DocsProperties';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_EXCEPTION(PIN_REJ, 'Свойство с мнемокодом ' || PIN_CODE || ' не найдено');
        RETURN; --- дальше искать нет смысла
    END;

    BEGIN
      -- Найдем значение свойства
      SELECT ZSV.STR_VALUE, ZSV.NUM_VALUE, ZSV.DATE_VALUE, NVL(ZSV.SOURCE, ZSV.SOURCE_EXT)
        INTO OUT_STR, OUT_NUM, OUT_DAT, OUT_SRC
        FROM PARUS.DOCS_PROPS_VALS ZSV
       WHERE ZSV.UNIT_RN = PIN_DOC
         AND ZSV.DOCS_PROP_RN = V_SV_RN
         AND ZSV.UNITCODE = PIN_UNI;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL; --- Если надо, то предупреждение выводили выше.
    END;
  END DPV;

  FUNCTION DOCS_PROPS_VALS_S(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_DOC IN NUMBER, PIN_CODE IN VARCHAR2, PIN_UNI IN VARCHAR2)
    RETURN VARCHAR2 AS

    V_RES_STR PARUS.DOCS_PROPS_VALS.STR_VALUE%TYPE;
    V_RES_NUM PARUS.DOCS_PROPS_VALS.NUM_VALUE%TYPE;
    V_RES_DAT PARUS.DOCS_PROPS_VALS.DATE_VALUE%TYPE;
    V_RES_SRC PARUS.DOCS_PROPS_VALS.SOURCE%TYPE;

  BEGIN
    PARUS.UDO_PKG_REP.DPV(PIN_COM, PIN_REJ, PIN_DOC, PIN_CODE, PIN_UNI, V_RES_STR, V_RES_NUM, V_RES_DAT, V_RES_SRC);

    RETURN V_RES_STR;

  END DOCS_PROPS_VALS_S;

  FUNCTION DOCS_PROPS_VALS_N(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_DOC IN NUMBER, PIN_CODE IN VARCHAR2, PIN_UNI IN VARCHAR2)
    RETURN NUMBER AS
    V_RES_STR PARUS.DOCS_PROPS_VALS.STR_VALUE%TYPE;
    V_RES_NUM PARUS.DOCS_PROPS_VALS.NUM_VALUE%TYPE;
    V_RES_DAT PARUS.DOCS_PROPS_VALS.DATE_VALUE%TYPE;
    V_RES_SRC PARUS.DOCS_PROPS_VALS.SOURCE%TYPE;

  BEGIN
    PARUS.UDO_PKG_REP.DPV(PIN_COM, PIN_REJ, PIN_DOC, PIN_CODE, PIN_UNI, V_RES_STR, V_RES_NUM, V_RES_DAT, V_RES_SRC);

    RETURN V_RES_NUM;

  END DOCS_PROPS_VALS_N;

  FUNCTION DOCS_PROPS_VALS_D(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_DOC IN NUMBER, PIN_CODE IN VARCHAR2, PIN_UNI IN VARCHAR2)
    RETURN DATE AS
    V_RES_STR PARUS.DOCS_PROPS_VALS.STR_VALUE%TYPE;
    V_RES_NUM PARUS.DOCS_PROPS_VALS.NUM_VALUE%TYPE;
    V_RES_DAT PARUS.DOCS_PROPS_VALS.DATE_VALUE%TYPE;
    V_RES_SRC PARUS.DOCS_PROPS_VALS.SOURCE%TYPE;
  BEGIN
    PARUS.UDO_PKG_REP.DPV(PIN_COM, PIN_REJ, PIN_DOC, PIN_CODE, PIN_UNI, V_RES_STR, V_RES_NUM, V_RES_DAT, V_RES_SRC);

    RETURN V_RES_DAT;

  END DOCS_PROPS_VALS_D;

  FUNCTION DOCS_PROPS_VALS_SRC(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_DOC IN NUMBER, PIN_CODE IN VARCHAR2, PIN_UNI IN VARCHAR2)
    RETURN NUMBER AS
    V_RES_STR PARUS.DOCS_PROPS_VALS.STR_VALUE%TYPE;
    V_RES_NUM PARUS.DOCS_PROPS_VALS.NUM_VALUE%TYPE;
    V_RES_DAT PARUS.DOCS_PROPS_VALS.DATE_VALUE%TYPE;
    V_RES_SRC PARUS.DOCS_PROPS_VALS.SOURCE%TYPE;
  BEGIN
    PARUS.UDO_PKG_REP.DPV(PIN_COM, PIN_REJ, PIN_DOC, PIN_CODE, PIN_UNI, V_RES_STR, V_RES_NUM, V_RES_DAT, V_RES_SRC);

    RETURN V_RES_SRC;

  END DOCS_PROPS_VALS_SRC;

  FUNCTION EXTRA_DICTS_VALS_S(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_ZN IN VARCHAR2, PIN_CODE IN VARCHAR2) RETURN VARCHAR2 AS
    V_RES EXTRA_DICTS_VALUES.NOTE%TYPE;
  BEGIN
    BEGIN
      SELECT SLV.NOTE
        INTO V_RES
        FROM EXTRA_DICTS SL, COMPVERLIST V, EXTRA_DICTS_VALUES SLV
       WHERE SL.CODE = PIN_CODE
         AND V.VERSION = SL.VERSION
         AND V.COMPANY = PIN_COM
         AND V.UNITCODE = 'ExtraDictionaries'
         AND SLV.PRN = SL.RN
         AND SLV.STR_VALUE = PIN_ZN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_EXCEPTION(PIN_REJ, 'Значение ' || PIN_ZN || ' не найдено в словаре ' || PIN_CODE);
        V_RES := '-';
    END;
    RETURN V_RES;

  END;

  FUNCTION EXTRA_DICTS_VALS_N(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_ZN IN NUMBER, PIN_CODE IN VARCHAR2) RETURN VARCHAR2 AS
    V_RES EXTRA_DICTS_VALUES.NOTE%TYPE;
  BEGIN
    BEGIN
      SELECT SLV.NOTE
        INTO V_RES
        FROM EXTRA_DICTS SL, COMPVERLIST V, EXTRA_DICTS_VALUES SLV
       WHERE SL.CODE = PIN_CODE
         AND V.VERSION = SL.VERSION
         AND V.COMPANY = PIN_COM
         AND V.UNITCODE = 'ExtraDictionaries'
         AND SLV.PRN = SL.RN
         AND SLV.NUM_VALUE = PIN_ZN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_EXCEPTION(PIN_REJ, 'Значение ' || PIN_ZN || ' не найдено в словаре ' || PIN_CODE);
        V_RES := '';
    END;
    RETURN V_RES;

  END;
  FUNCTION EXTRA_DICTS_VALS_D(PIN_COM IN NUMBER, PIN_REJ IN NUMBER, PIN_ZN IN DATE, PIN_CODE IN VARCHAR2) RETURN VARCHAR2 AS
    V_RES EXTRA_DICTS_VALUES.NOTE%TYPE;
  BEGIN
    BEGIN
      SELECT SLV.NOTE
        INTO V_RES
        FROM EXTRA_DICTS SL, COMPVERLIST V, EXTRA_DICTS_VALUES SLV
       WHERE SL.CODE = PIN_CODE
         AND V.VERSION = SL.VERSION
         AND V.COMPANY = PIN_COM
         AND V.UNITCODE = 'ExtraDictionaries'
         AND SLV.PRN = SL.RN
         AND SLV.DATE_VALUE = PIN_ZN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_EXCEPTION(PIN_REJ, 'Значение ' || PIN_ZN || ' не найдено в словаре ' || PIN_CODE);
        V_RES := '';
    END;
    RETURN V_RES;

  END;

  FUNCTION COMPANY_AGNLIST_NAME(PIN_COM IN NUMBER, PIN_REJ IN NUMBER) RETURN VARCHAR2 AS
    V_AGN AGNLIST.FULLNAME%TYPE;
  BEGIN
    BEGIN
      SELECT NVL(REPLACE(UDO_PKG_REP.DOCS_PROPS_VALS_S(PIN_COM, 1, A.RN, 'F_NAME', 'AGNLIST'), '/', CHR(10)), A.FULLNAME)
        INTO V_AGN
        FROM COMPANIES C, AGNLIST A
       WHERE C.RN = PIN_COM
         AND C.AGENT = A.RN(+);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_EXCEPTION(PIN_REJ,
                    'Организация для компании с RN ' || NVL(TO_CHAR(PIN_COM), '') || ' не найдена');
    END;
    RETURN V_AGN;
  END;

  FUNCTION COMPANY_AGNLIST_OKPO(PIN_COM IN NUMBER, PIN_REJ IN NUMBER) RETURN VARCHAR2 AS
    V_OKPO AGNLIST.ORGCODE%TYPE;
  BEGIN
    BEGIN
      SELECT A.ORGCODE
        INTO V_OKPO
        FROM COMPANIES C, AGNLIST A
       WHERE C.RN = PIN_COM
         AND C.AGENT = A.RN(+);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_EXCEPTION(PIN_REJ,
                    'Организация для компании с RN ' || NVL(TO_CHAR(PIN_COM), '') || ' не найдена');
    END;
    RETURN V_OKPO;
  END;

  FUNCTION COMPANY_RUK_RN(PIN_COM IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER) RETURN NUMBER AS
    V_RES AGNLIST.RN%TYPE; ---PIN_REJ 0-- Главный бухгалтер, 1- Руководитель
  BEGIN
    BEGIN
      FOR CUR IN (SELECT C.AGENT FROM COMPANIES C WHERE C.RN = PIN_COM) LOOP
        V_RES := UDO_PKG_REP.RUK_AGENT_RN(CUR.AGENT, PIN_DAT, PIN_REJ);
      END LOOP;
    END;
    RETURN V_RES;
  END;

  FUNCTION COMPANY_RUK_FIO(PIN_COM IN NUMBER, PIN_DAT IN DATE, PIN_REJ IN NUMBER, PIN_PADEJ in number default 0) RETURN VARCHAR2 AS
    --PIN_REJ 0-- Главный бухгалтер, 1- Руководитель
  BEGIN
    RETURN UDO_PKG_REP.AGENT_FIO(UDO_PKG_REP.COMPANY_RUK_RN(PIN_COM, PIN_DAT, PIN_REJ),PIN_PADEJ );
  END;

  FUNCTION NOMEN_IS_DRUG(PIN_COM IN NUMBER, NOMEN_RN IN NUMBER) RETURN NUMBER AS
    V_RES NUMBER(1);
  BEGIN
    BEGIN
      SELECT 1
        INTO V_RES
        FROM PARUS.NOMMODIF NM
       WHERE NM.PRN = NOMEN_RN
         AND PARUS.UDO_PKG_REP.DOCS_PROPS_VALS_S(PIN_COM  => PIN_COM,
                                                 PIN_REJ  => 1,
                                                 PIN_DOC  => NM.RN,
                                                 PIN_CODE => 'СЛП',
                                                 PIN_UNI  => 'NomenclatorModification') IS NOT NULL
         AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END;
    RETURN 1;

  END;

  FUNCTION NOMEN_IS_PKU(PIN_COM IN NUMBER, NOMEN_RN IN NUMBER) RETURN NUMBER IS
    --- Признак количественного учета из группы ЛС
    V_RES INTEGER;
  BEGIN

    SELECT nvl(MAX(T.PKU),0)
      INTO V_RES
      FROM PARUS.DRUG_REGISTR_GROUPS_SP T
     WHERE T.COMPANY = PIN_COM
       AND T.NOMENCLATURE = NOMEN_RN;
    RETURN V_RES;

  END;

  FUNCTION NOMEN_Q_UPACK(PIN_NOM_RN IN NUMBER) RETURN NUMBER IS
    V_RES NUMBER(17, 5); --- Количество ОЕИ в упаковке, если упаковки нет, то 1
  BEGIN
    BEGIN
      SELECT PAK.QUANT
        INTO V_RES
        FROM NOMNPACK PAK
       WHERE PAK.PRN = PIN_NOM_RN
         AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := 1;
    END;
    RETURN V_RES;
  END;

  FUNCTION MODIF_Q_UPACK(PIN_NOMNMODIFPACK IN NUMBER) RETURN NUMBER is
    V_RES NUMBER(17, 5); --- Количество ОЕИ в упаковке, если упаковки нет, то 1

  begin
    begin
      select UP.QUANT
        INTO V_RES
        from NOMNMODIFPACK MP, NOMNPACK UP
       where MP.RN = PIN_NOMNMODIFPACK
         and MP.Nomenpack = UP.rn;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := 1;
    END;
    RETURN V_RES;

  end;

  FUNCTION NOMEN_NAME_UPACK(PIN_NOM_RN IN NUMBER) RETURN varchar2 IS
    V_RES NOMNPACK.code%type; ---Наименование упаковки, если упаковки нет, то Null
  BEGIN
    BEGIN
      SELECT PAK.code
        INTO V_RES
        FROM NOMNPACK PAK
       WHERE PAK.PRN = PIN_NOM_RN
         AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := null;
    END;
    RETURN V_RES;
  END;

  FUNCTION NOMEN_IS_JNVLP(PIN_COM IN NUMBER, PIN_NOMEN IN NUMBER, PIN_MODIF IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    --- Признак ЖНВЛП по RN номенклатуры или модификации
    V_RES INTEGER;
  BEGIN

    IF PIN_NOMEN IS NOT NULL THEN
      V_RES := CASE PARUS.UDO_PKG_REP.DOCS_PROPS_VALS_S(PIN_COM  => PIN_COM,
                                                    PIN_REJ  => 1,
                                                    PIN_DOC  => PIN_NOMEN,
                                                    PIN_CODE => 'ЖНВЛП',
                                                    PIN_UNI  => 'Nomenclator')
                 WHEN 'Да' THEN
                  1
                 ELSE
                  0
               END;

    ELSIF PIN_MODIF IS NOT NULL THEN
      BEGIN
        SELECT CASE PARUS.UDO_PKG_REP.DOCS_PROPS_VALS_S(PIN_COM  => PIN_COM,
                                                    PIN_REJ  => 1,
                                                    PIN_DOC  => NM.PRN,
                                                    PIN_CODE => 'ЖНВЛП',
                                                    PIN_UNI  => 'Nomenclator')
                 WHEN 'Да' THEN
                  1
                 ELSE
                  0
               END
          INTO V_RES
          FROM PARUS.NOMMODIF NM
         WHERE NM.RN = PIN_MODIF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_RES := 0;
      END;
    ELSE
      V_RES := 0;
    END IF;

    RETURN V_RES;

  END;

  PROCEDURE CONST_VAL(PIN_COM   IN NUMBER,
                      PIN_CODE  IN VARCHAR2,
                      PIN_DATE  IN DATE,
                      PIN_REJ   IN NUMBER,
                      OUT_RES_S OUT VARCHAR2,
                      OUT_RES_N OUT NUMBER,
                      OUT_RES_D OUT DATE) IS

  BEGIN
    BEGIN
      --- Найдем значение на дату
      SELECT CV.NUMVALUE, CV.STRVALUE, CV.DATEVALUE
        INTO OUT_RES_N, OUT_RES_S, OUT_RES_D
        FROM CONSTLST CL, CONSTVAL CV
       WHERE CL.RN = CV.PRN
         AND CL.COMPANY = PIN_COM
         AND CL.NAME = PIN_CODE
         AND PIN_DATE BETWEEN CV.DATEFROM AND NVL(CV.DATETO, PIN_DATE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --- Пробуем считать основное значение
        BEGIN
          SELECT CL.NUMVALUE, CL.STRVALUE, CL.DATEVALUE
            INTO OUT_RES_N, OUT_RES_S, OUT_RES_D
            FROM CONSTLST CL
           WHERE CL.COMPANY = PIN_COM
             AND CL.NAME = PIN_CODE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            P_EXCEPTION(PIN_REJ,
                        'Значение константы "' || PIN_CODE || '" на дату ' || TO_CHAR(PIN_DATE, 'DD.MM.YYYY') || ' не найдено');
        END;
    END;
  END;

  FUNCTION CONST_VAL_S(PIN_COM NUMBER, PIN_CODE VARCHAR2, PIN_DATE DATE, PIN_REJ NUMBER) RETURN VARCHAR2 AS

    V_RES_S PARUS.CONSTVAL.STRVALUE%TYPE;
    V_RES_N PARUS.CONSTVAL.NUMVALUE%TYPE;
    V_RES_D PARUS.CONSTVAL.DATEVALUE%TYPE;

  BEGIN
    CONST_VAL(PIN_COM, PIN_CODE, PIN_DATE, PIN_REJ, V_RES_S, V_RES_N, V_RES_D);
    RETURN V_RES_S;
  END;

  FUNCTION CONST_VAL_N(PIN_COM IN NUMBER, PIN_CODE IN VARCHAR2, PIN_DATE IN DATE, PIN_REJ IN NUMBER) RETURN NUMBER IS
    V_RES_S PARUS.CONSTVAL.STRVALUE%TYPE;
    V_RES_N PARUS.CONSTVAL.NUMVALUE%TYPE;
    V_RES_D PARUS.CONSTVAL.DATEVALUE%TYPE;

  BEGIN
    CONST_VAL(PIN_COM, PIN_CODE, PIN_DATE, PIN_REJ, V_RES_S, V_RES_N, V_RES_D);
    RETURN V_RES_N;
  END;
  FUNCTION CONST_VAL_D(PIN_COM IN NUMBER, PIN_CODE IN VARCHAR2, PIN_DATE IN DATE, PIN_REJ IN NUMBER) RETURN DATE IS
    V_RES_S PARUS.CONSTVAL.STRVALUE%TYPE;
    V_RES_N PARUS.CONSTVAL.NUMVALUE%TYPE;
    V_RES_D PARUS.CONSTVAL.DATEVALUE%TYPE;

  BEGIN
    CONST_VAL(PIN_COM, PIN_CODE, PIN_DATE, PIN_REJ, V_RES_S, V_RES_N, V_RES_D);
    RETURN V_RES_D;
  END;

  FUNCTION NOMEN_IN_GR_LS(PIN_COM IN NUMBER, PIN_NOM IN NUMBER, PIN_CODE_GR IN VARCHAR2, pin_D1 in date , PIN_d2 in date, PIN_NO_RN in number default null, PIN_VID_MI in number default null) RETURN NUMBER IS
    V_NRES     NUMBER(1);
    SBLANK     VARCHAR2(20) := GET_OPTIONS_STR('EmptySymb');
    SDELIMITER VARCHAR2(20) := GET_OPTIONS_STR('SeqSymb');
    SNOTSYMB   VARCHAR2(20) := GET_OPTIONS_STR('NotSymb');
    SSTAR      VARCHAR2(20) := GET_OPTIONS_STR('StarSymb');
    SQUESTSYMB VARCHAR2(20) := GET_OPTIONS_STR('QuestSymb');
    V_Q number(3);

    S_CODE_GR VARCHAR2(2000) := REPLACE(REPLACE(PIN_CODE_GR, SSTAR, '%'), SQUESTSYMB, '_');

  BEGIN
    --- Если PIN_NO_RN задан, то указанная запись в группе ЛС не учитывается, чтоб при добавлении не считать самого себя

      SELECT count(distinct GRLS.rn)
        INTO V_Q
        FROM DRUG_REGISTR_GROUPS GRLS, DRUG_REGISTR_GROUPS_SP SG
       WHERE GRLS.COMPANY = PIN_COM
         and (PIN_VID_MI is null or GRLS.KIND = PIN_VID_MI)
         AND PARUS.UDO_F_STRINLIKE(GRLS.CODE, S_CODE_GR, SDELIMITER, SBLANK, SNOTSYMB) = 1
         AND GRLS.RN = SG.PRN
         and ( PIN_NO_RN is null or SG.rn != PIN_NO_RN)--- Для проверок при добавлении, чтоб запись сама себя не видела
         AND SG.NOMENCLATURE = PIN_NOM
         and not (nvl(PIN_D2, sg.date_beg) <  sg.date_beg or  nvl(sg.date_end, pin_D1) < PIN_d1)
         ;

    case V_Q when 0 then V_NRES := 0; --- не входит в группы
             when 1 then V_NRES := 1; --- входит 1 группу
             else   V_NRES := 2; -- Входит в несколько групп
    end case;

    RETURN V_NRES;
  END;

  FUNCTION GR_LS(PIN_COM IN NUMBER, PIN_NOM IN NUMBER, PIN_VID_RES IN VARCHAR2, PIN_D1 in date , PIN_D2 in date ,PIN_NO_RN in number default null, PIN_VID_MI in number default null) RETURN VARCHAR2 IS
    V_RES      VARCHAR2(2000) := '';
    SDELIMITER VARCHAR2(20) := PARUS.GET_OPTIONS_STR('SeqSymb');
  BEGIN
    --- Выводится код или наименованиегруппы ЛС (в зависимости от параметра)
    --- номенклатура может состоять в нескольких группах ЛС
    FOR CUR IN (SELECT distinct TRIM(RG.NAME) GLS_NAME, TRIM(RG.CODE) GLS_CODE
                  FROM PARUS.DRUG_REGISTR_GROUPS RG, PARUS.DRUG_REGISTR_GROUPS_SP SG
                 WHERE RG.COMPANY = PIN_COM
                   and (PIN_VID_MI is null or RG.KIND = PIN_VID_MI)
                   AND RG.RN = SG.PRN
                   and ( PIN_NO_RN is null or SG.rn != PIN_NO_RN)--- Для проверок при добавлении, чтоб запись сама себя не видела
                   AND SG.COMPANY = RG.COMPANY
                   AND SG.NOMENCLATURE = PIN_NOM
                   and not (nvl(PIN_D2, sg.date_beg) <  sg.date_beg or  nvl(sg.date_end, pin_D1) < PIN_d1)
                   ) LOOP
      CASE
        WHEN UPPER(PIN_VID_RES) = 'CODE' THEN
          V_RES := V_RES || SDELIMITER || CUR.GLS_CODE;
        ELSE
          V_RES := V_RES || SDELIMITER || CUR.GLS_NAME;
      END CASE;

    END LOOP;

    RETURN SUBSTR(V_RES, 2);
  END;

  FUNCTION KOMIS_ZAG(PIN_COM IN NUMBER, PIN_NAME IN VARCHAR2) RETURN SYS_REFCURSOR IS
    /* Функция выводит данные для заголовка комиссии, записывать их надо в
    TYPE TYP_ZAG IS RECORD(
                NRN      NUMBER(17), -- RN шапки комиссии
                Kom_Name VARCHAR2(240), -- Наименовании комиссии
                DOC_CODE VARCHAR2(240), -- Тип приказа комиссии
                DOC_NUMB VARCHAR2(240), -- Номер приказа комиссии
                DOC_DATE DATE -- Дата приказа комиссии
    );
    V_RES_ZAG TYP_ZAG; --- Запись заголовка*/
    CUR1 SYS_REFCURSOR;
  BEGIN
    OPEN CUR1 FOR
      SELECT KOM.RN, KOM.NAME, DT.DOCCODE, KOM.ORDER_NUMB, KOM.ORDER_DATE
        FROM PARUS.STANCOMM KOM, PARUS.DOCTYPES DT
       WHERE KOM.NAME = PIN_NAME
         AND KOM.COMPANY = PIN_COM
         AND KOM.ORDER_TYPE = DT.RN(+);

    RETURN CUR1;
  END;

  FUNCTION KOMIS_SOST(PIN_DOC IN NUMBER, PIN_DATE IN DATE) RETURN SYS_REFCURSOR IS
    /*  Функция возвращает состав постоянно действующей комиссии по RN на Дату, записывать надо в
    TYPE TYP_SOST IS RECORD(
       NN      NUMBER(2), --- Номер члена комиссии по порядку
       Emppost VARCHAR2(240), --- Должность члена комиссии
       FIO     VARCHAR2(240), --- ФИО члена комиссии
       PREZ    INTEGER -- Признак председателя комиссии
       );
       V_RES_SOST TYP_SOST; --- Запись состава*/

    CUR1 SYS_REFCURSOR;
  BEGIN

    OPEN CUR1 FOR
      SELECT SK.MEMBER_NUMBER,
             SK.EMPPOST,
             CASE A.AGNFAMILYNAME
               WHEN NULL THEN
                A.AGNABBR
               ELSE
                A.AGNFAMILYNAME || NVL2(A.AGNFIRSTNAME, ' ' || SUBSTR(A.AGNFIRSTNAME, 1, 1) || '.', '') ||
                NVL2(A.AGNLASTNAME, ' ' || SUBSTR(A.AGNLASTNAME, 1, 1) || '.', '')
             END FIO,
             SK.PRESIDENT
        FROM PARUS.STANCOMMSP SK, PARUS.AGNLIST A
       WHERE SK.PRN = PIN_DOC
         AND PIN_DATE BETWEEN SK.BEGIN_DATE AND SK.END_DATE
         AND SK.AGENT = A.RN
       ORDER BY SK.MEMBER_NUMBER;
    RETURN CUR1;
  END;

  FUNCTION DEPT_NAME_BY_CODE(PIN_COM IN NUMBER, PIN_CODE IN VARCHAR2, PIN_REJ IN VARCHAR2) RETURN VARCHAR2 IS

    V_RES PARUS.INS_DEPARTMENT.NAME%TYPE;

  BEGIN
    BEGIN
      SELECT (CASE UPPER(PIN_REJ)
               WHEN 'NOM' THEN
                DEP.NAME_NOM
               WHEN 'GEN' THEN
                DEP.NAME_GEN
               WHEN 'DAT' THEN
                DEP.NAME_DAT
               WHEN 'ACC' THEN
                DEP.NAME_ACC
               WHEN 'ABL' THEN
                DEP.NAME_ABL
               ELSE
                DEP.NAME
             END)
        INTO V_RES
        FROM PARUS.INS_DEPARTMENT DEP
       WHERE DEP.COMPANY = PIN_COM
         AND DEP.CODE = PIN_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := NULL;
    END;
    RETURN V_RES;
  END;

  FUNCTION MONTH_NAME(PIN_N IN NUMBER, PIN_REJ IN NUMBER) RETURN VARCHAR2 IS

  BEGIN
    RETURN(CASE PIN_N WHEN 1 THEN CASE PIN_REJ WHEN 1 THEN 'январь' ELSE 'января' END WHEN 2 THEN CASE PIN_REJ WHEN 1 THEN 'февраль' ELSE
           'февраля' END WHEN 3 THEN CASE PIN_REJ WHEN 1 THEN 'март' ELSE 'марта' END WHEN 4 THEN CASE PIN_REJ WHEN 1 THEN 'апрель' ELSE
           'апреля' END WHEN 5 THEN CASE PIN_REJ WHEN 1 THEN 'май' ELSE 'мая' END WHEN 6 THEN CASE PIN_REJ WHEN 1 THEN 'июнь' ELSE
           'июня' END WHEN 7 THEN CASE PIN_REJ WHEN 1 THEN 'июль' ELSE 'июля' END WHEN 8 THEN CASE PIN_REJ WHEN 1 THEN 'август' ELSE
           'августа' END WHEN 9 THEN CASE PIN_REJ WHEN 1 THEN 'сентябрь' ELSE 'сентября' END WHEN 10 THEN CASE PIN_REJ WHEN 1 THEN
           'октябрь' ELSE 'октября' END WHEN 11 THEN CASE PIN_REJ WHEN 1 THEN 'ноябрь' ELSE 'ноября' END WHEN 12 THEN CASE PIN_REJ WHEN 1 THEN
           'декабрь' ELSE 'декабря' END ELSE '' END);
  END;

  FUNCTION MONTH_NAME(PIN_D IN DATE, PIN_REJ IN NUMBER) RETURN VARCHAR2 IS
    V_N NUMBER(2) := TO_NUMBER(TO_CHAR(PIN_D, 'MM'));
  BEGIN
    RETURN MONTH_NAME(V_N, PIN_REJ);
  END;

  FUNCTION KVARTAL_NMB(PIN_N IN number) RETURN VARCHAR2 IS

  Begin

    RETURN(case when PIN_N between 1 and 3 then 'I' when PIN_N between 4 and 6 then 'II' when PIN_N between 7 and 9 then 'III' when
           PIN_N between 10 and 12 then 'IV' else null end);

  end;

  FUNCTION KVARTAL_NMB(PIN_D IN DATE) RETURN VARCHAR2 IS

  Begin
    return KVARTAL_NMB(to_number(TO_char(pin_D, 'MM')));

  end;

  FUNCTION OST_GY(PIN_COM IN NUMBER, PIN_GY IN NUMBER, PIN_DATE IN DATE, PIN_REJ IN VARCHAR2) RETURN NUMBER IS
    --- Остаток на дату по строке остатков ТМЦ по партиям
    V_Q PARUS.GOODSSUPPLY.RESTFACT%TYPE;
    V_S PARUS.GOODSSUPPLY.SUMMFACT%TYPE;
  BEGIN
    BEGIN
      SELECT GY.RESTFACT - NVL(SUM((2 * ST.OPER_TYPE - 1) * ST.QUANT), 0),
             GY.SUMMFACT - NVL(SUM((2 * ST.OPER_TYPE - 1) * ST.SUMMTAX), 0)
        INTO V_Q, V_S
        FROM PARUS.GOODSSUPPLY GY,
             (SELECT S.GOODSSUPPLY GYRN, S.OPER_TYPE, S.QUANT, S.SUMMTAX
                FROM PARUS.STOREOPERJOURN S
               WHERE S.GOODSSUPPLY = PIN_GY
                 AND S.COMPANY = PIN_COM
                 AND S.SIGNPLAN != 1
                 AND S.OPERDATE >= PIN_DATE) ST
       WHERE GY.RN = PIN_GY
         AND GY.RN = ST.GYRN(+)
       GROUP BY GY.RESTFACT, GY.SUMMFACT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_Q := 0;
        V_S := 0;
    END;
    RETURN CASE UPPER(PIN_REJ) WHEN 'Q' THEN V_Q ELSE V_S END;
  END;

  FUNCTION OST_NOMMODIF(PIN_COM IN NUMBER, PIN_NMRN IN NUMBER, PIN_DATE IN DATE, PIN_STORE IN VARCHAR2, PIN_REJ IN VARCHAR2)
    RETURN NUMBER IS
    --- Остаток на дату по Модификации номенклатуры , по складу (отобранным),  на начало даты
    V_Q PARUS.GOODSSUPPLY.RESTFACT%TYPE;
    V_S PARUS.GOODSSUPPLY.SUMMFACT%TYPE;

    SBLANK     VARCHAR2(20) := GET_OPTIONS_STR('EmptySymb');
    SDELIMITER VARCHAR2(20) := GET_OPTIONS_STR('SeqSymb');
    SNOTSYMB   VARCHAR2(20) := GET_OPTIONS_STR('NotSymb');
    SSTAR      VARCHAR2(20) := GET_OPTIONS_STR('StarSymb');
    SQUESTSYMB VARCHAR2(20) := GET_OPTIONS_STR('QuestSymb');

    S_CODE_SKL VARCHAR2(2000) := REPLACE(REPLACE(PIN_STORE, SSTAR, '%'), SQUESTSYMB, '_');

  BEGIN

    BEGIN
      SELECT SUM(GY.RESTFACT - NVL(ST.Q, 0)) Q, SUM(GY.SUMMFACT - NVL(ST.S, 0)) S
        INTO V_Q, V_S
        FROM GOODSPARTIES GP,
             GOODSSUPPLY GY,
             AZSAZSLISTMT SKL,
             (SELECT S.GOODSSUPPLY, SUM((2 * S.OPER_TYPE - 1) * S.QUANT) Q, SUM((2 * S.OPER_TYPE - 1) * S.SUMMTAX) S
                FROM STOREOPERJOURN S
               WHERE S.COMPANY = PIN_COM
                 AND S.SIGNPLAN != 1
                 AND S.OPERDATE >= PIN_DATE
               GROUP BY S.GOODSSUPPLY) ST
       WHERE GP.NOMMODIF = PIN_NMRN
         AND GP.COMPANY = PIN_COM
         AND GY.PRN = GP.RN
         AND GY.COMPANY = GP.COMPANY
         AND GY.STORE = SKL.RN
         AND GY.RN = ST.GOODSSUPPLY(+)
         AND (PIN_STORE IS NULL OR PARUS.UDO_F_STRINLIKE(SKL.AZS_NUMBER, S_CODE_SKL, SDELIMITER, SBLANK, SNOTSYMB) = 1)
         AND SKL.COMPANY = GP.COMPANY;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_Q := 0;
        V_S := 0;

    END;

    RETURN CASE UPPER(PIN_REJ) WHEN 'Q' THEN V_Q ELSE V_S END;

  END;


  FUNCTION OST_NOMMODIF(PIN_COM IN NUMBER, PIN_NMRN IN NUMBER, PIN_DATE IN DATE, PIN_STORE IN Number, PIN_REJ IN VARCHAR2)
    RETURN NUMBER IS
    --- Остаток на дату по Модификации номенклатуры , по складу (ОДНОМУ ЗАДАННОМУ),  на начало даты
    V_Q PARUS.GOODSSUPPLY.RESTFACT%TYPE;
    V_S PARUS.GOODSSUPPLY.SUMMFACT%TYPE;



  BEGIN

    BEGIN
      SELECT SUM(GY.RESTFACT - NVL(ST.Q, 0)) Q, SUM(GY.SUMMFACT - NVL(ST.S, 0)) S
        INTO V_Q, V_S
        FROM GOODSPARTIES GP,
             GOODSSUPPLY GY,
             (SELECT S.GOODSSUPPLY, SUM((2 * S.OPER_TYPE - 1) * S.QUANT) Q, SUM((2 * S.OPER_TYPE - 1) * S.SUMMTAX) S
                FROM STOREOPERJOURN S
               WHERE S.COMPANY = PIN_COM
                 AND S.SIGNPLAN != 1
                 AND S.OPERDATE >= PIN_DATE
               GROUP BY S.GOODSSUPPLY) ST
       WHERE GP.NOMMODIF = PIN_NMRN
         AND GP.COMPANY = PIN_COM
         AND GY.PRN = GP.RN
         AND GY.COMPANY = GP.COMPANY
         AND GY.STORE = PIN_STORE
         AND GY.RN = ST.GOODSSUPPLY(+);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_Q := 0;
        V_S := 0;

    END;

    RETURN CASE UPPER(PIN_REJ) WHEN 'Q' THEN V_Q ELSE V_S END;

  END;

  FUNCTION VID_TMC_KOSGU(PIN_KOSGU IN VARCHAR2) RETURN NUMBER IS
    V_RES NUMBER(2);
  BEGIN
    CASE
      WHEN PIN_KOSGU IN ('340.2', '341.1') THEN
        --- Лекарственные средства
        V_RES := 1;
      WHEN PIN_KOSGU IN ('340.3', '341.2') THEN
        --- перевязочные медикаменты
        V_RES := 2;
      WHEN PIN_KOSGU IN ('340.8', '341.3') THEN
        --- Вспомогательные материалы
        V_RES := 3;
      ELSE
        V_RES := 0; --- прочее
    END CASE;
    RETURN V_RES;

  END;

  FUNCTION NDS_RATE(PIN_TAX_GR IN VARCHAR2, PIN_COMPANY IN NUMBER, PIN_DATE IN DATE DEFAULT SYSDATE) RETURN NUMBER IS
    --- Вычисление ставки налоговой группы на заданную дату в организации  по коду группы
    V_RES PARUS.DICTAXIS.P_VALUE%TYPE;
  BEGIN
    SELECT NVL(MAX(DX.P_VALUE), 0)
      INTO V_RES
      FROM PARUS.DICTAXGR T, PARUS.COMPVERLIST V, PARUS.DICTAXIS DX
     WHERE T.CODE = PIN_TAX_GR
       AND V.VERSION = T.VERSION
       AND V.UNITCODE = 'TaxiesGroups'
       AND V.COMPANY = PIN_COMPANY
       AND DX.TAX_GROUP = T.RN
       AND DX.COMPANY = V.COMPANY
       AND DX.BEG_DATE = (SELECT MAX(DXT.BEG_DATE)
                            FROM PARUS.DICTAXIS DXT
                           WHERE DXT.TAX_GROUP = T.RN
                             AND DXT.COMPANY = V.COMPANY
                             AND DXT.BEG_DATE < PIN_DATE);
    RETURN V_RES;
  END;

  FUNCTION NDS_RATE(PIN_TAX_GR IN NUMBER, PIN_COMPANY IN NUMBER, PIN_DATE IN DATE DEFAULT SYSDATE) RETURN NUMBER IS
    --- Вычисление ставки налоговой группы на заданную дату в организации  по её RN
    V_RES PARUS.DICTAXIS.P_VALUE%TYPE;
  BEGIN
    SELECT NVL(MAX(DX.P_VALUE), 0)
      INTO V_RES
      FROM PARUS.DICTAXGR T, PARUS.COMPVERLIST V, PARUS.DICTAXIS DX
     WHERE T.RN = PIN_TAX_GR
       AND V.VERSION = T.VERSION
       AND V.UNITCODE = 'TaxiesGroups'
       AND V.COMPANY = PIN_COMPANY
       AND DX.TAX_GROUP = T.RN
       AND DX.COMPANY = V.COMPANY
       AND DX.BEG_DATE = (SELECT MAX(DXT.BEG_DATE)
                            FROM PARUS.DICTAXIS DXT
                           WHERE DXT.TAX_GROUP = T.RN
                             AND DXT.COMPANY = V.COMPANY
                             AND DXT.BEG_DATE < PIN_DATE);
    RETURN V_RES;
  END;

  FUNCTION STOREOPERJOURN_CONTRAGENT(PIN_DOC IN NUMBER, PIN_UNI IN VARCHAR2, PIN_OUT IN VARCHAR2) RETURN VARCHAR2 IS
    /* функция возращвет от кого - кому по записи строки Журнала складских операций */
    --- В зависимости от pin_OUT возвращает:
    V_CODE_FROM VARCHAR2(80); --- код  От кого
    V_NAME_FROM VARCHAR2(255); --- наименование от кого
    V_CODE_TO   VARCHAR2(80); --- код  Куда
    V_NAME_TO   VARCHAR2(255); --- Наименование Куда

  BEGIN
    CASE PIN_UNI
      WHEN 'IncomingOrders' THEN
        --- Приходные ордера
        BEGIN
          SELECT A.AGNABBR, A.AGNNAME, SKL.AZS_NUMBER, SKL.AZS_NAME
            INTO V_CODE_FROM, V_NAME_FROM, V_CODE_TO, V_NAME_TO
            FROM STOREOPERJOURN ST, DOCLINKS L, INORDERS I, AGNLIST A, AZSAZSLISTMT SKL
           WHERE ST.RN = PIN_DOC
             AND L.OUT_DOCUMENT = ST.RN
             AND L.IN_UNITCODE = ST.UNITCODE
             AND L.OUT_UNITCODE = 'StoreOpersJournal'
             AND L.OUT_COMPANY = ST.COMPANY
             AND L.IN_COMPANY = L.OUT_COMPANY
             AND I.RN = L.IN_DOCUMENT
             AND A.RN = I.CONTRAGENT
             AND I.STORE = SKL.RN;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      WHEN 'GoodsTransInvoicesToDepts' THEN
        ---- Расходные накладные на отпуск в подразделения
        BEGIN
          SELECT NVL(DEP.CODE, SKL.AZS_NUMBER),
                 NVL(DEP.NAME, SKL.AZS_NAME),
                 NVL(DEP_IN.CODE, SKL_IN.AZS_NUMBER),
                 NVL(DEP_IN.NAME, SKL_IN.AZS_NAME)
            INTO V_CODE_FROM, V_NAME_FROM, V_CODE_TO, V_NAME_TO
            FROM STOREOPERJOURN ST,
                 DOCLINKS       L,
                 TRANSINVDEPT   T,
                 AZSAZSLISTMT   SKL,
                 AZSAZSLISTMT   SKL_IN,
                 INS_DEPARTMENT DEP,
                 INS_DEPARTMENT DEP_IN
           WHERE ST.RN = PIN_DOC
             AND L.OUT_DOCUMENT = ST.RN
             AND L.IN_UNITCODE = ST.UNITCODE
             AND L.OUT_UNITCODE = 'StoreOpersJournal'
             AND L.OUT_COMPANY = ST.COMPANY
             AND L.IN_COMPANY = L.OUT_COMPANY
             AND T.RN = L.IN_DOCUMENT
             AND T.STORE = SKL.RN
             AND T.IN_STORE = SKL_IN.RN(+)
             AND SKL.DEPARTMENT = DEP.RN(+)
             AND SKL_IN.DEPARTMENT = DEP_IN.RN(+);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      WHEN 'GoodsTransInvoicesToConsumers' THEN
        BEGIN
          SELECT NVL(DEP.CODE, SKL.AZS_NUMBER), NVL(DEP.NAME, SKL.AZS_NAME), A.AGNABBR, A.AGNNAME
            INTO V_CODE_FROM, V_NAME_FROM, V_CODE_TO, V_NAME_TO
            FROM STOREOPERJOURN ST, DOCLINKS L, TRANSINVCUST I, AGNLIST A, AZSAZSLISTMT SKL, INS_DEPARTMENT DEP
           WHERE ST.RN = PIN_DOC
             AND L.OUT_DOCUMENT = ST.RN
             AND L.IN_UNITCODE = ST.UNITCODE
             AND L.OUT_UNITCODE = 'StoreOpersJournal'
             AND L.OUT_COMPANY = ST.COMPANY
             AND L.IN_COMPANY = L.OUT_COMPANY
             AND I.RN = L.IN_DOCUMENT
             AND A.RN = I.AGENT
             AND I.STORE = SKL.RN
             AND SKL.DEPARTMENT = DEP.RN(+);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      WHEN 'ReturnInvoicesToSuppliers' THEN
        ---- Расходные накладные на возврат поставщикам
        begin
          SELECT NVL(DEP.CODE, SKL.AZS_NUMBER), NVL(DEP.NAME, SKL.AZS_NAME), A.AGNABBR, A.AGNNAME
            INTO V_CODE_FROM, V_NAME_FROM, V_CODE_TO, V_NAME_TO
            FROM STOREOPERJOURN ST, DOCLINKS L, RINVTOSUP I, AGNLIST A, AZSAZSLISTMT SKL, INS_DEPARTMENT DEP
           WHERE ST.RN = PIN_DOC
             AND L.OUT_DOCUMENT = ST.RN
             AND L.IN_UNITCODE = ST.UNITCODE
             AND L.OUT_UNITCODE = 'StoreOpersJournal'
             AND L.OUT_COMPANY = ST.COMPANY
             AND L.IN_COMPANY = L.OUT_COMPANY
             AND I.RN = L.IN_DOCUMENT
             AND A.RN = I.SUPPLIER
             AND I.STORE = SKL.RN
             AND SKL.DEPARTMENT = DEP.RN(+);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;

      when 'SheepDirectToConsumers' then
        --- распоряжения на потребителей
        SELECT NVL(DEP.CODE, SKL.AZS_NUMBER), NVL(DEP.NAME, SKL.AZS_NAME), A.AGNABBR, A.AGNNAME
          INTO V_CODE_FROM, V_NAME_FROM, V_CODE_TO, V_NAME_TO
          FROM STOREOPERJOURN ST, DOCLINKS L, SHEEPDIRSCUST I, AGNLIST A, AZSAZSLISTMT SKL, INS_DEPARTMENT DEP
         WHERE ST.RN = PIN_DOC
           AND L.OUT_DOCUMENT = ST.RN
           AND L.IN_UNITCODE = ST.UNITCODE
           AND L.OUT_UNITCODE = 'StoreOpersJournal'
           AND L.OUT_COMPANY = ST.COMPANY
           AND L.IN_COMPANY = L.OUT_COMPANY
           AND I.RN = L.IN_DOCUMENT
           AND I.AGENT = A.RN
           AND I.STORE = SKL.RN
           AND SKL.DEPARTMENT = DEP.RN(+);

      ELSE
        NULL;

    END CASE;

    CASE PIN_OUT
      WHEN 'CODE_FROM' THEN
        RETURN V_CODE_FROM;
      WHEN 'NAME_FROM' THEN
        RETURN V_NAME_FROM;
      WHEN 'CODE_TO' THEN
        RETURN V_CODE_TO;
      WHEN 'NAME_TO' THEN
        RETURN V_NAME_TO;
      ELSE
        RETURN NULL;
    END CASE;

  END;

  FUNCTION STOREOPERJOURN_MOL(PIN_DOC IN NUMBER, PIN_UNI IN VARCHAR2, PIN_OUT IN VARCHAR2) RETURN VARCHAR2 IS
    /* функция возращвет МОЛ от  кого - кому по записи строки Журнала складских операций */
    -- В зависимости от pin_OUT возвращает:

    -- 'CODE_FROM' , 'NAME_FROM' , 'CODE_TO' ,  'NAME_TO'

    V_CODE_FROM VARCHAR2(80); --- код  От кого
    V_NAME_FROM VARCHAR2(255); --- наименование от кого
    V_CODE_TO   VARCHAR2(80); --- код  Куда
    V_NAME_TO   VARCHAR2(255); --- Наименование Куда

  BEGIN
    CASE PIN_UNI
      WHEN 'IncomingOrders' THEN
        --- Приходные ордера
        BEGIN
          SELECT A.AGNABBR, -- В приходнике МОЛ от кого нет, выводим контрагента
                 A.AGNNAME,
                 CASE
                   WHEN MOL_IN.AGNFAMILYNAME IS NULL THEN
                    MOL_IN.AGNABBR
                   ELSE
                    MOL_IN.AGNFAMILYNAME || CASE
                      WHEN MOL_IN.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL_IN.AGNFIRSTNAME, 1, 1) || '.'
                    END || CASE
                      WHEN MOL_IN.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL_IN.AGNLASTNAME, 1, 1) || '.'
                    END
                 END,
                 CASE
                   WHEN MOL_IN.AGNFAMILYNAME IS NULL THEN
                    MOL_IN.AGNNAME
                   ELSE
                    MOL_IN.AGNFAMILYNAME || CASE
                      WHEN MOL_IN.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL_IN.AGNFIRSTNAME
                    END || CASE
                      WHEN MOL_IN.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL_IN.AGNLASTNAME
                    END
                 END
            INTO V_CODE_FROM, V_NAME_FROM, V_CODE_TO, V_NAME_TO
            FROM STOREOPERJOURN ST, DOCLINKS L, INORDERS I, AGNLIST A, AZSAZSLISTMT SKL, AGNLIST MOL_IN
           WHERE ST.RN = PIN_DOC
             AND L.OUT_DOCUMENT = ST.RN
             AND L.IN_UNITCODE = ST.UNITCODE
             AND L.OUT_UNITCODE = 'StoreOpersJournal'
             AND L.OUT_COMPANY = ST.COMPANY
             AND L.IN_COMPANY = L.OUT_COMPANY
             AND I.RN = L.IN_DOCUMENT
             AND A.RN = I.CONTRAGENT
             AND I.STORE = SKL.RN
             AND SKL.AZS_AGENT = MOL_IN.RN(+);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      WHEN 'GoodsTransInvoicesToDepts' THEN
        ---- Расходные накладные на отпуск в подразделения
        BEGIN
          SELECT CASE
                   WHEN MOL.AGNFAMILYNAME IS NULL THEN
                    MOL.AGNABBR
                   ELSE
                    MOL.AGNFAMILYNAME || CASE
                      WHEN MOL.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL.AGNFIRSTNAME, 1, 1) || '.'
                    END || CASE
                      WHEN MOL.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL.AGNLASTNAME, 1, 1) || '.'
                    END
                 END,
                 CASE
                   WHEN MOL.AGNFAMILYNAME IS NULL THEN
                    MOL.AGNNAME
                   ELSE
                    MOL.AGNFAMILYNAME || CASE
                      WHEN MOL.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL.AGNFIRSTNAME
                    END || CASE
                      WHEN MOL.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL.AGNLASTNAME
                    END
                 END,
                 CASE
                   WHEN MOL_IN.AGNFAMILYNAME IS NULL THEN
                    MOL_IN.AGNABBR
                   ELSE
                    MOL_IN.AGNFAMILYNAME || CASE
                      WHEN MOL_IN.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL_IN.AGNFIRSTNAME, 1, 1) || '.'
                    END || CASE
                      WHEN MOL_IN.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL_IN.AGNLASTNAME, 1, 1) || '.'
                    END
                 END,
                 CASE
                   WHEN MOL_IN.AGNFAMILYNAME IS NULL THEN
                    MOL_IN.AGNNAME
                   ELSE
                    MOL_IN.AGNFAMILYNAME || CASE
                      WHEN MOL_IN.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL_IN.AGNFIRSTNAME
                    END || CASE
                      WHEN MOL_IN.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL_IN.AGNLASTNAME
                    END
                 END
            INTO V_CODE_FROM, V_NAME_FROM, V_CODE_TO, V_NAME_TO
            FROM STOREOPERJOURN ST, DOCLINKS L, TRANSINVDEPT T, AGNLIST MOL, AGNLIST MOL_IN
           WHERE ST.RN = PIN_DOC
             AND L.OUT_DOCUMENT = ST.RN
             AND L.IN_UNITCODE = ST.UNITCODE
             AND L.OUT_UNITCODE = 'StoreOpersJournal'
             AND L.OUT_COMPANY = ST.COMPANY
             AND L.IN_COMPANY = L.OUT_COMPANY
             AND T.RN = L.IN_DOCUMENT
             AND T.MOL = MOL.RN
             AND T.IN_MOL = MOL_IN.RN(+);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      WHEN 'GoodsTransInvoicesToConsumers' THEN
        ---- Расходные накладные на отпуск потребителям
        BEGIN
          SELECT CASE
                   WHEN MOL.AGNFAMILYNAME IS NULL THEN
                    MOL.AGNABBR
                   ELSE
                    MOL.AGNFAMILYNAME || CASE
                      WHEN MOL.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL.AGNFIRSTNAME, 1, 1) || '.'
                    END || CASE
                      WHEN MOL.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL.AGNLASTNAME, 1, 1) || '.'
                    END
                 END,
                 CASE
                   WHEN MOL.AGNFAMILYNAME IS NULL THEN
                    MOL.AGNNAME
                   ELSE
                    MOL.AGNFAMILYNAME || CASE
                      WHEN MOL.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL.AGNFIRSTNAME
                    END || CASE
                      WHEN MOL.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL.AGNLASTNAME
                    END
                 END,
                 A.AGNABBR,
                 A.AGNNAME
            INTO V_CODE_FROM, V_NAME_FROM, V_CODE_TO, V_NAME_TO
            FROM STOREOPERJOURN ST, DOCLINKS L, TRANSINVCUST I, AGNLIST A, AGNLIST MOL
           WHERE ST.RN = PIN_DOC
             AND L.OUT_DOCUMENT = ST.RN
             AND L.IN_UNITCODE = ST.UNITCODE
             AND L.OUT_UNITCODE = 'StoreOpersJournal'
             AND L.OUT_COMPANY = ST.COMPANY
             AND L.IN_COMPANY = L.OUT_COMPANY
             AND I.RN = L.IN_DOCUMENT
             AND A.RN = I.AGENT
             AND I.MOL = MOL.RN(+);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      when 'ReturnInvoicesToSuppliers' then
        --- расходные накладные на возврат поставщикам
        BEGIN
          SELECT CASE
                   WHEN MOL.AGNFAMILYNAME IS NULL THEN
                    MOL.AGNABBR
                   ELSE
                    MOL.AGNFAMILYNAME || CASE
                      WHEN MOL.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL.AGNFIRSTNAME, 1, 1) || '.'
                    END || CASE
                      WHEN MOL.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || SUBSTR(MOL.AGNLASTNAME, 1, 1) || '.'
                    END
                 END,
                 CASE
                   WHEN MOL.AGNFAMILYNAME IS NULL THEN
                    MOL.AGNNAME
                   ELSE
                    MOL.AGNFAMILYNAME || CASE
                      WHEN MOL.AGNFIRSTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL.AGNFIRSTNAME
                    END || CASE
                      WHEN MOL.AGNLASTNAME IS NULL THEN
                       ''
                      ELSE
                       ' ' || MOL.AGNLASTNAME
                    END
                 END,
                 A.AGNABBR,
                 A.AGNNAME
            INTO V_CODE_FROM, V_NAME_FROM, V_CODE_TO, V_NAME_TO
            FROM STOREOPERJOURN ST, DOCLINKS L, RINVTOSUP I, AGNLIST A, AGNLIST MOL
           WHERE ST.RN = PIN_DOC
             AND L.OUT_DOCUMENT = ST.RN
             AND L.IN_UNITCODE = ST.UNITCODE
             AND L.OUT_UNITCODE = 'StoreOpersJournal'
             AND L.OUT_COMPANY = ST.COMPANY
             AND L.IN_COMPANY = L.OUT_COMPANY
             AND I.RN = L.IN_DOCUMENT
             AND A.RN = I.SUPPLIER
             AND I.MOL = MOL.RN(+);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;

      ELSE
        NULL;
    END CASE;

    CASE PIN_OUT
      WHEN 'CODE_FROM' THEN
        RETURN V_CODE_FROM;
      WHEN 'NAME_FROM' THEN
        RETURN V_NAME_FROM;
      WHEN 'CODE_TO' THEN
        RETURN V_CODE_TO;
      WHEN 'NAME_TO' THEN
        RETURN V_NAME_TO;
      ELSE
        RETURN NULL;
    END CASE;

  END;

  FUNCTION ACCOUNTING_ENTRY(PIN_DOC IN NUMBER, PIN_IN_NOM IN NUMBER, PIN_UNI_NOM in Varchar2) RETURN SYS_REFCURSOR IS

    --PIN_DOC  -- RN ПРОВОДКИ Финансово-хоз операции
    --PIN_IN_NOM -- 1 -- только с заполненной номенклатурой, 0 -- все
    --PIN_UNI_NOM  -- Если задан код раздела, то взять неоменклатуру из документа из которого растет ФХО
    ---  раздел документа указан в параметре

    /*  Функция Дб, Кр и пять уровней аналитики
    TYPE TYP_FHO IS RECORD(
       DB   VARCHAR2(40), -- Счет Дб
       DBA1 VARCHAR2(40), -- Аналит. Дб. первого уровня
       DBA2 VARCHAR2(40), -- Аналит. Дб. вторго уровня
       DBA3 VARCHAR2(40), -- Аналит. Дб. третьего уровня
       DBA4 VARCHAR2(40), -- Аналит. Дб. четвертого уровня
       DBA5 VARCHAR2(40), -- Аналит. Дб. пятого уровня
       KR   VARCHAR2(40), -- Счет Кр
       KRA1 VARCHAR2(40), -- Аналит. Кр. первого уровня
       KRA2 VARCHAR2(40), -- Аналит. Кр. вторго уровня
       KRA3 VARCHAR2(40), -- Аналит. Кр. третьего уровня
       KRA4 VARCHAR2(40), -- Аналит. Кр. четвертого уровня
       KRA5 VARCHAR2(40), --  Аналит. Кр. пятого уровня
       PBE_DB VARCHAR2(20), --- ПБЕ Дб
       PBE_KR VARCHAR2(20),  --- ПБЕ Кр
       NOMEN_RN number(17) -- RN Номенклатуры
       FHO_SP_RN number(17) -- RN  проводки
       );
       */

    CUR2 SYS_REFCURSOR;
  BEGIN

    OPEN CUR2 FOR
      SELECT DISTINCT DB.ACC_NUMBER,
                      DBA1.ANL_NUMBER,
                      DBA2.ANL_NUMBER,
                      DBA3.ANL_NUMBER,
                      DBA4.ANL_NUMBER,
                      DBA5.ANL_NUMBER,
                      KR.ACC_NUMBER,
                      KRA1.ANL_NUMBER,
                      KRA2.ANL_NUMBER,
                      KRA3.ANL_NUMBER,
                      KRA4.ANL_NUMBER,
                      KRA5.ANL_NUMBER,
                      DBPBE.BUNIT_MNEMO,
                      KRPBE.BUNIT_MNEMO,
                      SP.ACNT_SUM,
                      SP.ACNT_QUANT,
                      NVL(SP.NOMENCLATURE,
                          case
                            when PIN_UNI_NOM is null then
                             null
                            when PIN_UNI_NOM = 'InternalDocuments' then --- Если номенклатуры нет в проводке найдем ее в спецификации !!! внутреннего документа
                             (SELECT MAX(SP1.NOMENCLATURE)
                                FROM DOCLINKS L, INTDOCS_SP SP1
                               WHERE L.OUT_DOCUMENT = PIN_DOC
                                 AND L.IN_UNITCODE = 'InternalDocumentsSpecs'
                                 AND L.OUT_COMPANY = SP.Company
                                 AND L.IN_COMPANY = L.OUT_COMPANY
                                 AND L.OUT_UNITCODE = 'EconomicOperationsSpecs'
                                 AND SP1.RN = L.IN_DOCUMENT)
                            else --- Поищем в товарном отчете
                             (SELECT MAX(SP1.NOMENCLATURE)
                                FROM DOCLINKS L, SALESREPORTDETAIL SP1
                               WHERE L.OUT_DOCUMENT = PIN_DOC
                                 AND L.IN_UNITCODE = 'TradeReportsSp'
                                 AND L.OUT_COMPANY = SP.Company
                                 AND L.IN_COMPANY = L.OUT_COMPANY
                                 AND L.OUT_UNITCODE = 'EconomicOperationsSpecs'
                                 AND SP1.RN = L.IN_DOCUMENT)
                          end),
                      SP.rn
        FROM OPRSPECS SP,
             DICACCS  DB,
             DICANLS  DBA1,
             DICANLS  DBA2,
             DICANLS  DBA3,
             DICANLS  DBA4,
             DICANLS  DBA5,
             DICACCS  KR,
             DICANLS  KRA1,
             DICANLS  KRA2,
             DICANLS  KRA3,
             DICANLS  KRA4,
             DICANLS  KRA5,
             DICBUNTS DBPBE,
             DICBUNTS KRPBE

       WHERE SP.RN = PIN_DOC
         AND (PIN_IN_NOM = 0 OR SP.NOMENCLATURE IS NOT NULL)

         AND SP.ACCOUNT_DEBIT = DB.RN(+)
         AND SP.ANALYTIC_DEBIT1 = DBA1.RN(+)
         AND SP.ANALYTIC_DEBIT2 = DBA2.RN(+)
         AND SP.ANALYTIC_DEBIT3 = DBA3.RN(+)
         AND SP.ANALYTIC_DEBIT4 = DBA4.RN(+)
         AND SP.ANALYTIC_DEBIT5 = DBA5.RN(+)

         AND SP.ACCOUNT_CREDIT = KR.RN(+)
         AND SP.ANALYTIC_CREDIT1 = KRA1.RN(+)
         AND SP.ANALYTIC_CREDIT2 = KRA2.RN(+)
         AND SP.ANALYTIC_CREDIT3 = KRA3.RN(+)
         AND SP.ANALYTIC_CREDIT4 = KRA4.RN(+)
         AND SP.ANALYTIC_CREDIT5 = KRA5.RN(+)

         AND SP.BALUNIT_DEBIT = DBPBE.RN(+)
         AND SP.BALUNIT_CREDIT = KRPBE.RN(+);
    RETURN CUR2;
  END;
  FUNCTION PARUS_USER_AGNABBR(PIN_COM IN NUMBER, PIN_SV_CODE IN VARCHAR2 DEFAULT 'PARUS_USER') RETURN VARCHAR2 IS
    V_RES AGNLIST.AGNABBR%TYPE;
  BEGIN
    BEGIN
      SELECT AG.AGNABBR
        INTO V_RES
        FROM DOCS_PROPS SV, COMPVERLIST V, DOCS_PROPS_VALS SVZ, AGNLIST AG
       WHERE SV.CODE = PIN_SV_CODE
         AND SV.VERSION = V.VERSION
         AND V.COMPANY = PIN_COM
         AND V.UNITCODE = 'DocsProperties'
         AND SVZ.DOCS_PROP_RN = SV.RN
         AND SVZ.STR_VALUE = USER
         AND ROWNUM = 1
         AND AG.RN = SVZ.UNIT_RN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_RES := NULL;
    END;
    RETURN V_RES;
  END;

  PROCEDURE SOTR_ATTR(PIN_DOC      IN NUMBER,
                      PIN_COM      IN NUMBER,
                      PIN_DATE     IN DATE,
                      OUT_DOL      OUT VARCHAR2,
                      OUT_DEP_CODE OUT VARCHAR2,
                      OUT_DEP_NAME OUT VARCHAR2) AS

  BEGIN

    SELECT DOL.PSDEP_NAME, OTD.CODE, OTD.NAME
      INTO OUT_DOL, OUT_DEP_CODE, OUT_DEP_NAME
      FROM CLNPERSONS CP, CLNPSPFM PM, CLNPSPFMTYPES CT, CLNPSDEP DOL, INS_DEPARTMENT OTD
     WHERE CP.PERS_AGENT = PIN_DOC
       AND PIN_DATE BETWEEN NVL(CP.LAST_JOBBEG_DATE, CP.JOBBEGIN_DATE) AND NVL(CP.DISMISS_DATE, PIN_DATE)
       AND PM.PERSRN = CP.RN
       AND CP.COMPANY = PIN_COM
       AND PM.CLNPSPFMTYPES = CT.RN
       AND CT.IS_PRIMARY = 1
       AND PIN_DATE BETWEEN PM.BEGENG AND NVL(PM.ENDENG, PIN_DATE)
       AND PM.PSDEPRN = DOL.RN(+)
       AND PM.DEPTRN = OTD.RN
       AND ROWNUM = 1; --- Два значения нам не надо!

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;

  END;

  FUNCTION DEL_LAST_CHAR(PIN_STR IN VARCHAR2, PIN_DEL_SYMB IN VARCHAR2, PIN_NUMB IN NUMBER) RETURN VARCHAR2 IS
    V_RES  VARCHAR2(2000) := PIN_STR;
    V_N    INTEGER(2) := PIN_NUMB;
    V_LS   NUMBER(2) := LENGTH(PIN_DEL_SYMB);
    V_LRES NUMBER(5) := LENGTH(PIN_STR);
  BEGIN

    LOOP
      EXIT WHEN V_N = 0 OR SUBSTR(V_RES, -V_LS, V_LS) != PIN_DEL_SYMB;
      V_N    := V_N - 1;
      V_LRES := V_LRES - V_LS;
      V_RES  := SUBSTR(V_RES, 1, V_LRES);
    END LOOP;

    RETURN(V_RES);

  END;

  FUNCTION FRAC_PART_NUMBER(PIN_NUMBER IN NUMBER, PIN_TR_1 IN NUMBER, PIN_TR_2 IN NUMBER) RETURN VARCHAR2 IS

    -- Выводит не менее PIN_TR_1 после запятой и не более PIN_TR_2
    -- Недостающие позиции дополняет нулями '0'
    -- PIN_NUMBER математически округляется до PIN_TR_2 знаков после запятой
    -- PIN_TR_1 >= 0

    V_NUMBER NUMBER(17, 7) := ROUND(PIN_NUMBER, PIN_TR_2); --- Округлим
    V_FRAC   VARCHAR2(40) := NVL(RPAD(SUBSTR(TO_CHAR(MOD(V_NUMBER, 1)), 2), PIN_TR_2, '0'), RPAD('0', PIN_TR_1 + 1, '0')); --- Дополнили нулями до PIN_TR_1 + 1  знаков
    V_RES    VARCHAR2(40) := TO_CHAR(TRUNC(V_NUMBER)) || '.'; --- Целая часть
  BEGIN
    RETURN CASE SUBSTR(V_FRAC, -1) WHEN '0' THEN V_RES || UDO_PKG_REP.DEL_LAST_CHAR(V_FRAC, '0', LENGTH(V_FRAC) - PIN_TR_1) ELSE V_RES || SUBSTR(V_FRAC,
                                                                                                                                                 1,
                                                                                                                                                 PIN_TR_2) END;
  END;

END UDO_PKG_REP;
/
