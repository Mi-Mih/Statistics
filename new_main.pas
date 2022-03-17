program matstat;

{Переменные}
var
     {массив, куда будет записываться ошибка - error_arr}
     error_arr: array[1..1000] of real;

    {массив координаты - coord
     массив времени - time}
    coord,time: array[0..1000] of real;
    {массив с найденными предиктыми зн-ями x,y,z}
    x_y_z:array[0..2] of real;
    {средняя ошибка - E
    время упреждения - t_upr
    шаг по времени - dt
    левая граница координатного отрезка по времени - left_border_t
    правая граница координатного отрезка по времени - rigth border_t}
    E, t_upr, dt, left_border_t, right_border_t:real;

    {расчитываемая ошибка - error
     траектория прямая coord=b_0+b_1*t
     коэффициент прямой b_0 - input_b0
     коэффициент прямой b_1 - input_b1}
    error,b0_x,b1_x,b0_y,b1_y,b0_z,b1_z:real;
    {индекс для циклов по массивам - i
    число засечек - n}
    i,n:integer;
    {mato -мат ожидание
     dispersion -дисперсия
     quadr_dif - среднее квадратичное отклонение}
     mato,dispers,quadr_otkl:real;

{функции power}
Function power (os: real; st: integer):real;
            {Возведение вещественного числа   в  целочисленную  степень.}
                     begin
                       if st < 0 then
                          power:=1/power(os,abs(st))
                       else
                         if st > 0 then
                            power:=os*power(os,st-1)
                         else
                            power:=1;
                     end; {функции power}

{функция Powd}
 Function Powd(a,b: real): real;
            {Возведение вещественного числа  в вещественную степень.}
                      begin
                        if a > 0 then
                                 powd:=exp(b*ln(a))
                        else
                          if a < 0 then
                                   powd:=exp(b*ln(abs(a)))
                          else
                            if b = 0 then powd:=1
                            else powd:=0;
                      end;   {функция Powd}

{нормальный датчик (0,1)}
                 Function DAHOP(): real;
                        Var
                     i    : byte;
                     a,aa : real;
                       begin
                         a:=0;
                         for i:=1 to 12 do
                           begin
                             aa:=random;
                             a:=a+aa;
                           end;
                         Dahop:=(a-6);
                       end;
 {нормальный датчик (0,1)}


{ФУНКЦИЯ РАСЧЁТА ПРЕДИКТОВОГО ЗН-Я КООРДИНАТЫ}

{функция расчёта ошибки, состоит из:
1) внесение ошибки в исходные данные
2)экстраполирование функции методом наименьших квадратов(МНК)
3)Расчёт пердиктового зн-я}
{принимает на вход массивы x и t, время упреждения t_upr, среднюю ошибку E, коэффициенты b0 и b1, n - число засечек}
Function predict_coord(var coord,time: array of real; t_upr,E,dt,input_b0,input_b1:real;  n:integer):real;
var

   {error- искомая ошибка, prediction - предиктовое зн-е}
   prediction:real;
   {переменные, необходимые для МНК}
        {индекс для циклов по массивам - i}
         i : integer ;
         {вспомогательные массивы сумм для МНК
         sum_coord - sum(coord)
         sum_t - sum(t)
         sum_t_2 - sum(t^2)
         sum_coord_t - sum(coord*t)}
         sum_coord, sum_t, sum_t_2, sum_coord_t:real;
         {Искомые коэффициенты экстропалирующей прямой  coord=b_0+b_1*t}
         b_0, b_1:real;

begin

{1 часть - внесение ошибки в исходные данные}
for i:=0 to n-1 do
begin
     time[i]:=i*dt;
     coord[i]:=(input_b0+input_b1*i*dt)+E*DAHOP(); {точное зн-е + ошибка}
end;
{1 часть - внесение ошибки в исходные данные}

{2 часть - экстраполирование функции методом наименьших квадратов(МНК)}
         sum_coord:=0;
         sum_t:=0;
         sum_t_2:=0;
         sum_coord_t:=0;

      {считаем необходимые суммы: sum(coord), sum(t^2),sum(t),sum(coord*t)}
      for i:=0 to n-1 do
      begin
            sum_coord := sum_coord + coord[i];
            sum_t_2:=sum_t_2+power(time[i],2);
            sum_t:=sum_t+time[i];
            sum_coord_t:=sum_coord_t+time[i]*coord[i];
      end;
      {считаем необходимые суммы: sum(coord), sum(t^2),sum(t),sum(coord*t)}

      {ищем коэффициенты прямой coord=b_0+b_1*t}
      {расчёт b_0}
      b_0:=(sum_coord*sum_t_2-sum_t*sum_coord_t)/(n*sum_t_2-power(sum_t,2));
      {расчёт b_1}
      b_1:=(n*sum_coord_t-sum_t*sum_coord)/(n*sum_t_2-power(sum_t,2));
     {2 часть - экстраполирование функции методом наименьших квадратов(МНК)}

     {3 часть - расчёт пердиктового зн-я}
     prediction:=b_0+b_1*(time[n-1]+t_upr);
 {3 часть - расчёт пердиктового зн-я}
end;
{ФУНКЦИЯ РАСЧЁТА ПРЕДИКТОВОГО ЗН-Я КООРДИНАТЫ}


{ФУНКЦИЯ РАСЧЁТА ПРЕДИКТОВОЙ ТОЧКИ}
{Функция использует ф-ции, вычисляющие проекции точки}
Function predict_point(var x_y_z:array of real; t_upr,E,dt:real; n:integer):boolean;
begin
   x_y_z[0]:=predict_coord(coord, time, t_upr, E, dt, b0_x, b1_x, n);
   x_y_z[1]:=predict_coord(coord, time, t_upr, E, dt, b0_y, b1_y, n);
   x_y_z[2]:=predict_coord(coord, time, t_upr, E, dt, b0_z, b1_z, n);
end;
{ФУНКЦИЯ РАСЧЁТА ПРЕДИКТОВОЙ ТОЧКИ}

{фУНКЦИЯ РАСЧЁТА МАТ ОЖИДАНИЯ}
Function calc_mat_expect(var data: array of real): real;
var
    i: integer;
    mat_expect: real;
begin
    mat_expect := 0;
    for i := 0 to Length(data)-1 do
    begin
    mat_expect := mat_expect + data[i] / Length(data);
    end;
end;
{ФУНКЦИЯ РАСЧЁТА МАТ ОЖИДАНИЯ}

{ФУНКЦИЯ РАСЧЁТА ДИСПЕРСИИ}
function calc_dispersion(var data: array of real): real;
var
    i: integer;
    mat_expect, dispersion: real;
begin
    dispersion:=0;
    mat_expect := calc_mat_expect(data);
    for i := 0 to Length(data)-1 do
    begin
        dispersion := dispersion + power(data[i] - mat_expect, 2) / (Length(data)-1);
    end;

end;
{ФУНКЦИЯ РАСЧЁТА ДИСПЕРСИИ}

{ФУНКЦИЯ РАСЧЁТА СРЕДНЕГО КВАДРАТИЧНОГО ОТКЛОНЕНИЯ}
function calc_average_quadr_diff(var data: array of real): real;
var
    i: integer;
    mat_expect, dispersion,quadr_diff: real;
begin
    dispersion:=0;
    quadr_diff:=0;
    mat_expect := calc_mat_expect(data);
    for i := 0 to Length(data)-1 do
    begin
        dispersion := dispersion + power((data[i] - mat_expect), 2) / (Length(data)-1);
    end;
    quadr_diff:=Powd(dispersion,1/2);
end;
{ФУНКЦИЯ РАСЧЁТА СРЕДНЕГО КВАДРАТИЧНОГО ОТКЛОНЕНИЯ}

{ФУНКЦИЯ РАСЧЁТА ОШИБКА}
Function calc_error(var x_y_z:array of real;t_upr,E,dt:real;n:integer):real;
var
    x,y,z,pred_vec,exact_vec:real;
begin
 x:=b0_x+b1_x*(dt*(n-1)+t_upr);
 y:=b0_y+b1_y*(dt*(n-1)+t_upr);
 z:=b0_z+b1_z*(dt*(n-1)+t_upr);

 predict_point(x_y_z,t_upr,E,dt, n);
 pred_vec:=Powd(power(x_y_z[0],2)+power(x_y_z[1],2)+power(x_y_z[2],2),1/2);

 exact_vec:=Powd(power(x,2)+power(y,2)+power(z,2),1/2);
 error:=abs(pred_vec-exact_vec);
end;
{ФУНКЦИЯ РАСЧЁТА ОШИБКА}


begin {ГЛАВНАЯ ЧАСТЬ ПРОГРАММЫ}
{Вводим коэффициенты, определяющие траекторию полёта цели
для прямой coord=b0+b1*t}
b0_x:=25.0;
b1_x:=45.0;
b0_y:=25.0;
b1_y:=45.0;
b0_z:=25.0;
b1_z:=45.0;
{Вводим коэффициенты, определяющие траекторию полёта цели
для прямой coord=b0+b1*t}

{Вводим границы временного отрезка}
left_border_t:=0;
right_border_t:=10;
{Вводим границы временного отрезка}


{РАСЧЁТ ПАРАМЕТРОВ ОШИБКИ ПРИ ИЗМЕНЕНИИ ЧИСЛА ЗАСЕЧЕК - n}
{Фикс параметры}
t_upr:=0.0;
E:=0.0;
{Фикс параметры}

{Расчёт ошибки}
for i:=2 to Length(error_arr) do
begin
     error_arr[i-1]:=calc_error(x_y_z,t_upr,E,(left_border_t - right_border_t)/i,i);
end;
{Расчёт ошибки}

{Расчёт параметров мат ожидания, дисперсии, ср кв отклонения}
mato:=calc_mat_expect(error_arr);

dispers:= calc_dispersion(error_arr);

quadr_otkl:=calc_average_quadr_diff(error_arr);
{Расчёт параметров мат ожидания, дисперсии, ср кв отклонения}

writeln('Mathematical expected ',mato);
writeln('Dispersion ',dispers);
writeln('Average quadratic deviation ',quadr_otkl);
{РАСЧЁТ ПАРАМЕТРОВ ОШИБКИ ПРИ ИЗМЕНЕНИИ ЧИСЛА ЗАСЕЧЕК - n}

{РАСЧЁТ ПАРАМЕТРОВ ОШИБКИ ПРИ ИЗМЕНЕНИИ ВРЕМЕНИ УПРЕЖДЕНИЯ - t_upr}
{Фикс параметры}
E:=0.0;
dt:=1.0;
n:=10;
{Фикс параметры}

{Расчёт ошибки}
for i:=1 to Length(error_arr)-1 do
begin
     error_arr[i]:=calc_error(x_y_z,i/100,E,dt,n);
end;
{Расчёт ошибки}

{Расчёт параметров мат ожидания, дисперсии, ср кв отклонения}
mato:=calc_mat_expect(error_arr);

dispers:= calc_dispersion(error_arr);

quadr_otkl:=calc_average_quadr_diff(error_arr);
{Расчёт параметров мат ожидания, дисперсии, ср кв отклонения}

writeln('Mathematical expected ',mato);
writeln('Dispersion ',dispers);
writeln('Average quadratic deviation ',quadr_otkl);
{РАСЧЁТ ПАРАМЕТРОВ ОШИБКИ ПРИ ИЗМЕНЕНИИ ВРЕМЕНИ УПРЕЖДЕНИЯ - t_upr}


{РАСЧЁТ ПАРАМЕТРОВ ОШИБКИ ПРИ ИЗМЕНЕНИИ СРЕДИННОЙ ОШИБКИ- E}
{Фикс параметры}
t_upr:=0.0;
dt:=1.0;
n:=10;
{Фикс параметры}

{Расчёт ошибки}
for i:=1 to Length(error_arr)-1 do
begin
     error_arr[i]:=calc_error(x_y_z,t_upr,i/100,dt,n);
end;
{Расчёт ошибки}

{Расчёт параметров мат ожидания, дисперсии, ср кв отклонения}
mato:=calc_mat_expect(error_arr);

dispers:= calc_dispersion(error_arr);

quadr_otkl:=calc_average_quadr_diff(error_arr);
{Расчёт параметров мат ожидания, дисперсии, ср кв отклонения}

writeln('Mathematical expected ',mato);
writeln('Dispersion ',dispers);
writeln('Average quadratic deviation ',quadr_otkl);
{РАСЧЁТ ПАРАМЕТРОВ ОШИБКИ ПРИ ИЗМЕНЕНИИ СРЕДИННОЙ ОШИБКИ- E}

{РАСЧЁТ ПАРАМЕТРОВ ОШИБКИ ПРИ ИЗМЕНЕНИИ величины отрезка(шага по времени)- dt}
{Фикс параметры}
t_upr:=0.0;
E:=0.0;
n:=10;
{Фикс параметры}

{Расчёт ошибки}
for i:=1 to Length(error_arr)-1 do
begin
     error_arr[i]:=calc_error(x_y_z,t_upr,E,i/10,n);
end;
{Расчёт ошибки}

{Расчёт параметров мат ожидания, дисперсии, ср кв отклонения}
mato:=calc_mat_expect(error_arr);

dispers:= calc_dispersion(error_arr);

quadr_otkl:=calc_average_quadr_diff(error_arr);
{Расчёт параметров мат ожидания, дисперсии, ср кв отклонения}

writeln('Mathematical expected ',mato);
writeln('Dispersion ',dispers);
writeln('Average quadratic deviation ',quadr_otkl);
{РАСЧЁТ ПАРАМЕТРОВ ОШИБКИ ПРИ ИЗМЕНЕНИИ величины отрезка(шага по времени)- dt}
readln();
end.
{ГЛАВНАЯ ЧАСТЬ ПРОГРАММЫ} 
