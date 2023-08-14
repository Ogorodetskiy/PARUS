create or replace procedure drug_P_NOMCLASSIF_SMART_INS(PIN_COM in companies.rn%type,
                                                        PIN_CODE in NOMCLASSIF.CODE%type,
                                                        PIN_NAME in NOMCLASSIF.Name%type,
                                                        OUT_HRN  OUT NOMCLASSIF.HRN%TYPE,
                                                        OUT_NRN  out NOMCLASSIF.RN%TYPE) is

  V_HL    integer;
  V_HCODE NOMCLASSIF.CODE%type;

  ---- Процедура создания иерархии и всех отсутствующих вышестоящих иерархий

Begin

  V_HL := instr(PIN_CODE, '.', -1);
  
  if V_HL = 0 then
    --- Это каталог верхнего уровня (и он отсутствует, т.к. мы вызвали эту процедуру) Все проверки внее ее!
  
    P_NOMCLASSIF_BASE_INSERT(nCOMPANY => PIN_COM,
                             nHRN     => null,
                             sCODE    => PIN_CODE,
                             sNAME    => PIN_NAME,
                             sNOTE    => null,
                             nRN      => OUT_NRN);
    OUT_HRN := null;
  
  Else
    ---0 Вышестояший код
    V_HCODE := substr(PIN_CODE, 1, V_HL - 1);
    --- 1. Находим вышестоящую иерархию (первый раз)
  
    begin
    
      select N.RN
        into OUT_HRN
        from NOMCLASSIF N
        join compverlist V
          on V.version = N.VERSION
         and V.COMPANY = PIN_COM
         and V.Unitcode = 'NomenclatorClassifier'
       where N.CODE = V_HCODE;
      ---2. Если не нашли, то создаем ее
    exception
      when NO_DATA_FOUND then
      
      ---- Начало рекурсии!
      
        drug_P_NOMCLASSIF_SMART_INS(PIN_COM  => PIN_COM,
                                    PIN_CODE => V_HCODE,
                                    PIN_NAME => V_HCODE,
                                    OUT_HRN  => OUT_HRN,
                                    OUT_NRN  => OUT_NRN);
      
    end;
  
    --- 3. Находим RN  вышестоящей иерархии (внутри рекурсии)
  
    select N.RN
      into OUT_HRN
      from NOMCLASSIF N
      join compverlist V
        on V.version = N.VERSION
       and V.COMPANY = PIN_COM
       and V.Unitcode = 'NomenclatorClassifier'
     where N.CODE = V_HCODE;
  
    ---4. Создаем найденную иерархию
    P_NOMCLASSIF_BASE_INSERT(nCOMPANY => PIN_COM,
                             nHRN     => OUT_HRN,
                             sCODE    => PIN_CODE,
                             sNAME    => PIN_NAME,
                             sNOTE    => null,
                             nRN      => OUT_NRN);
  
    --- Конец рекурсии
  end if;

end;
