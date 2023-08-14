Declare
  PIN_COM  number(17) := 62910;
  PIN_CODE varchar2(255) := '10.02.03.77';
  PIN_NAME varchar2(255) := 'Новая категория 10.02.03.77';

  V_NRN NOMCLASSIF.RN%TYPE;
  V_HRN NOMCLASSIF.HRN%TYPE;

  V_HL integer;

begin

  begin
  
    select N.RN, N.HRN
      into V_NRN, V_HRN
      from NOMCLASSIF N
      join compverlist V
        on V.version = N.VERSION
       and V.COMPANY = PIN_COM
       and V.Unitcode = 'NomenclatorClassifier'
     where N.CODE = PIN_CODE;
  
  exception
    when NO_DATA_FOUND then  --- Если такого кода нет, то создаем его
      
    --- проверить что наименование уникально?
    
      drug_P_NOMCLASSIF_SMART_INS(PIN_COM => PIN_COM, PIN_CODE => PIN_CODE, PIN_NAME => PIN_NAME, OUT_HRN => V_HRN, OUT_NRN => V_NRN);
    
  end;

  dbms_output.put_line(V_HRN||' '||V_NRN);

end;