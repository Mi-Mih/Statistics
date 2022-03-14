program matstat;
{программа вычисляет ошибку производимого РЛК расчёта координаты
летательного аппарата}

{Переменные}
var
    {массив координаты - coord
     массив времени - time}
    coord,time: array[0..1000] of real;
    {средняя ошибка - E
    время упреждения - t_upr
    шаг по времени - dt
    левая граница координатного отрезка - left_border_x
    правая граница координатного отрезка - rigth border_x}
    E, t_upr, dt, left_border_x, right_border_x:real;

    {расчитываемая ошибка - error
     траектория прямая y=b_0+b_1*x
     коэффициент прямой b_0 - input_b0
     коэффициент прямой b_1 - input_b1}
    error,input_b0,input_b1:real;
    {индекс для циклов по массивам - i
    число засечек - n}
    i,n:integer;
    {Текстовая переменная для записи в файл - f}
    f:text;

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


{ФУНКЦИЯ РАСЧЁТА ОШИБКИ}

{функция расчёта ошибки, состоит из:
1) внесение ошибки в исходные данные
2)экстраполирование функции методом наименьших квадратов(МНК)
3)Расчёт пердиктового зн-я и сравнение с точным}
{принимает на вход массивы x и t, время упреждения t_upr, среднюю ошибку E, коэффициенты b0 и b1, n - число засечек}
Function calc_error(var coord,time: array of real; t_upr,E,dt,input_b0,input_b1:real;  n:integer):real;
var

   {error- искомая ошибка, prediction - предиктовое зн-е}
   error, prediction:real;
   {переменные, необходимые для МНК}
        {индекс для циклов по массивам - i}
         i : integer ;
         {вспомогательные массивы сумм для МНК
         sum_coord - sum(coord)
         sum_t - sum(t)
         sum_t_2 - sum(t^2)
         sum_coord_t - sum(coord*t)}
         sum_coord, sum_t, sum_t_2, sum_coord_t:real;
         {Искомые коэффициенты экстропалирующей прямой  y=b_0+b_1*x}
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

      {ищем коэффициенты прямой y=b_0+b_1*x}
      {расчёт b_0}
      b_0:=(sum_coord*sum_t_2-sum_t*sum_coord_t)/(n*sum_t_2-power(sum_t,2));
      {расчёт b_1}
      b_1:=(n*sum_coord_t-sum_t*sum_coord)/(n*sum_t_2-power(sum_t,2));
     {2 часть - экстраполирование функции методом наименьших квадратов(МНК)}

     {3 часть - расчёт пердиктового зн-я и сравнение с точным}
       prediction:=b_0+b_1*(time[n-1]+t_upr); {предикт}

    {ищем ошибку = точное - предикт}
    error:=abs((input_b0+input_b1*((n-1)*dt+t_upr))-prediction);
 {3 часть - расчёт пердиктового зн-я и сравнение с точным}
end;
{ФУНКЦИЯ РАСЧЁТА ОШИБКИ}


begin {Главная часть программы}
{Запись в файл}
assign(f,'data.csv');
rewrite(f);
t_upr:=0.0;
E:=0.0;
dt:=1.0;
input_b0:=20.0;
input_b1:=45.0;
n:=10;
error:=calc_error(coord, time, t_upr, E, dt, input_b0, input_b1, n);
writeln(error);
readln();
end.
{Главная часть программы}
