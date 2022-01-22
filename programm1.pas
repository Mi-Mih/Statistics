program programm1;
const n : integer =4;
const k : integer =5;
const t_upr : real =5.6;

var
   {Массивы координата(время), учитывай k - количество точек и n кол-во измерений}
   time,x: array [0..5] of real;
   diff_x_arr,x_predict_arr : array [0..4] of real;
   i,j,v: integer;
   eps,difference_x, disperssion_x,suma:real;

   {массив, содержащий 2 коэффа b_0 и b_1}
   solution:array [0..1] of real;

   {нормальный датчик (0,1) }
                 Function DAHOP: real;
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
                         Dahop:=(a-6)/0.6745;
                       end; {function DAHOR}
{------------------------------------------------------------power        --}

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

{фунция МНК, прямая}
function MNK(var coord,time,solution: array of real): boolean;
      var
      {index массива}
         i : integer ;
         {размер массива}
         n: integer;
         {вспомогательные массивы сумм для МНК}
         sum_coord:real;
         sum_t:real;
         sum_t_2:real;
         sum_coord_t:real;
         {Искомые коэффициенты}
         b_0:real;
         b_1:real;
      begin
         sum_coord:=0;
         sum_t:=0;
         sum_t_2:=0;
         sum_coord_t:=0;
      {размер берём по массиву времени}
      n:=length(time);

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

      {то, что возвращаем: массив найденных коэффов}
      solution[0]:=b_0;
      solution[1]:=b_1;
end;
Function x_exact(t: real): real;
            var 
            result: real;
            {зависимость координаты от времени- прямая.}
                      begin
                        result:=2.5+4.5*t;
                      end;
Function x_predict(b_0,b_1,x_p:real):real;
         var 
         pred:real;
         begin
         pred:=b_0*x_p+b_1;
         end;
{Головная программа!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{пока просто наполняем массивы координаты и времени}
begin
suma:=0;
disperssion_x:=0;
for j:=1 to n do
begin {цикл по ошибке}
eps:=j*1.0;
for i:=0 to k do
begin  {цикл по точке}
{вид функции можно ввести здесь}
       x[i]:=x_exact(i)+DAHOP*eps;
       time[i]:=i;
end;   {цикл по точке}
MNK(x,time,solution);
{writeln('y=',solution[0],'+',solution[1],'*x');}
difference_x:=abs(x_exact(k+t_upr)-x_predict(solution[0],solution[1],k+t_upr));
diff_x_arr[j]:=difference_x;
x_predict_arr[j]:=x_predict(solution[0],solution[1],k+t_upr);
end; {цикл по ошибке}

for v:=0 to n do{цикл для среднего}
begin {среднее значение для расчёта дисперсии}
suma:=suma+x_predict_arr[v];
end;{цикл для среднего}
suma:=suma/n;
for v:=0 to n do{цикл для дисперсии}
begin
disperssion_x:=disperssion_x+power(x_predict_arr[v]-suma,2)/(n-1);
writeln(disperssion_x);

end;{цикл для дисперсии}

writeln(disperssion_x);
readln();
end.

