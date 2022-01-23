program programm1;
const n : integer =4;
const k : integer =5;


var
   {Массивы координата(время), учитывай k - количество точек и n кол-во измерений}
   f:text;
   time,x: array [0..5] of real;{k}
   diff_x_arr,x_predict_arr,x_exact_arr, diff_x_arr_upr : array [0..4] of real; {n}
   i,j,v: integer;
   eps,difference_x, disperssion_x,suma, t_upr, help:real;
   t_upr_arr:array [0..10] of real;
   {для построения графика ошибки от числа засечек}
   x_zas: array of real;
   t_zas: array of real;
   {массив, содержащий 2 коэффа b_0 и b_1}
   solution:array [0..1] of real;

  
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
 {нормальный датчик (0,1) }
                 Function DAHOP(): real;
                     {   Var
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
                       end; {function DAHOR} }

                   var
                   ra:real;
                   begin
                   ra:=exp((-1/2)*(power(random,2)))/sqrt(2*pi);
                   end;

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

            {зависимость координаты от времени- прямая.}
                      begin
                        result:=25+45*t;
                      end;
Function x_predict(b_0,b_1,x_p:real):real;
         var 
         pred:real;
         begin
         pred:=b_0+b_1*x_p;
         end;

{Головная программа!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{пока просто наполняем массивы координаты и времени}
begin
t_upr:=1;
for i:=0 to n do
begin
eps:=DAHOP();
for j:=0 to k do
begin
x[j]:=x_exact(j)+eps;
time[j]:=j;
end;
MNK(x,time,solution);
{writeln('y=',solution[0],'+',solution[1],'*x');}
 {массив ошибок}
diff_x_arr[i]:=abs(x_exact(k+t_upr)-x_predict(solution[0],solution[1],k+t_upr));
{массив предиктов}
x_predict_arr[i]:=x_predict(solution[0],solution[1],k+t_upr);
{массив точных решений}
x_exact_arr[i]:=x_exact(k+t_upr);
end;
suma:=0;
disperssion_x:=0;
   for v:=0 to n Do{цикл для среднего}
   begin
    suma:=suma+x_predict_arr[v];
     end;
suma:=suma/(n+1);{среднее}

for v:=0 to n do{цикл для sum(dx/n)}
begin
disperssion_x:=disperssion_x+power(x_predict_arr[v]-suma,1);
end;{цикл для sum(dx/n)}
disperssion_x:=disperssion_x/(length(x_predict_arr));


{Запись значений ошибки в файл csv}
assign(f,'data.csv');
rewrite(f);
writeln(f,'Ошибка от возмущения');
for i:=0 to length(diff_x_arr) do
begin
writeln(f, diff_x_arr[i]);
end;


{зависимость ошибки от t_upr}
{assign(f,'data.csv'); }
help:=DAHOP();
writeln(f,'ошибка от упредительного времени', help);

for j:=0 to k do
begin
x[j]:=x_exact(j)+help;
time[j]:=j;
end;
for i:=0 to length(t_upr_arr) do
      begin
         t_upr:=t_upr+i;
         t_upr_arr[i]:=t_upr;
         MNK(x,time,solution);
       {writeln('y=',solution[0],'+',solution[1],'*x');}
 {массив ошибок}
diff_x_arr_upr[i]:=abs(x_exact(k+t_upr)-x_predict(solution[0],solution[1],k+t_upr));

writeln(f, diff_x_arr_upr[i], t_upr);
end;

writeln(f,'ошибка от числа засечек', help);
close(f);
end.   
