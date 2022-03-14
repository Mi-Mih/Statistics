program matstat;

var
   {массив координаты - coord
    массив времени - time}
    coord,time: array[0..1000] of real;
    {средняя ошибка - E
    время упреждения - t_upr
    шаг по времени - dt
    левая граница координатного отрезка - left_border_x
    правая граница координатного отрезка - rigth border_x}
    E,t_upr,dt,left_border_x,right_border_x:real;

    err,input_b0,input_b1:real;
    {индекс для циклов по массивам - i
    число засечек - n }
    i,n:integer;
    {Текстовая переменная для записи в файл - f}
    f:text;


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
                      end;   {Powd}
 {нормальный датчик (0,1) }
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



{функция расчёта ошибки по иксу}
{принимает на вход массивы x и t, t_upr, среднюю ошибку, коэффициенты b0 и b1, n - число засечек}
Function calc_err_x(var coord,time: array of real; t_upr,E,dt,input_b0,input_b1:real;  n:integer):real;
var

   {err-искомая ошибка, prediction - предиктовое зн-е}
   error, output:real;
   {MNK}
        {index массива}
         i : integer ;
         {размер массива}
         k: integer;
         {вспомогательные массивы сумм для МНК}
         sum_coord, sum_t, sum_t_2, sum_coord_t:real;
         {Искомые коэффициенты}
         b_0, b_1:real;

begin
{Заполняем массивы координаты и времени}
for i:=0 to n-1 do
begin
     time[i]:=i*dt;
     coord[i]:=(input_b0+input_b1*i*dt)+E*DAHOP(); {точное зн-е + ошибка}
end;

{Заполняем массивы координаты и времени}

{MNK}
         sum_coord:=0;
         sum_t:=0;
         sum_t_2:=0;
         sum_coord_t:=0;
      {размер берём по массиву времени}


      {ищем прямую y=b_0+b_1*x}
      {считаем необходимые суммы: sum(coord), sum(t^2),sum(t),sum(coord*t)}
      for i:=0 to n-1 do
      begin
            sum_coord := sum_coord + coord[i];
            sum_t_2:=sum_t_2+power(time[i],2);
            sum_t:=sum_t+time[i];
            sum_coord_t:=sum_coord_t+time[i]*coord[i];
      end;
      {b_0}
      b_0:=(sum_coord*sum_t_2-sum_t*sum_coord_t)/(n*sum_t_2-power(sum_t,2));
      {b_1}
      b_1:=(n*sum_coord_t-sum_t*sum_coord)/(n*sum_t_2-power(sum_t,2));
      {output=b_0+b_1*x}
       output:=b_0+b_1*(coord[n-1]+t_upr);
for i:=0 to n-1 do
    begin
      time[i]:=i*dt;
      coord[i]:=input_b0+input_b1*i*dt; {точное зн-е + ошибка}
       end;

{ищем ошибку = точное - полученное}
    error:=abs((input_b0+input_b1*(coord[n-1]+t_upr))-output);

end;
{функция расчёта ошибки по иксу}




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
err:=calc_err_x(coord,time,t_upr,E,dt,input_b0,input_b1,n);

readln();
end.
