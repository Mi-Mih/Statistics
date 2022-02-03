program matstat;

var
    err_arr: array[0..15-3] of real;
    dt_arr:array[0..10-3] of real;
    eps, t_upr,dt:real;

   i,n:integer;

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
                         Dahop:=(a-6)/0.6745;
                       end;
                   {var
                   ra:real;
                   begin
                   ra:=abs(exp((-1/2)*(power(random,2)))/sqrt(2*pi));
                   end; }

{фунция МНК, прямая}
function MNK(var coord,time: array of real; input:real): real;
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
         output:real;
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
      output:=b_0+b_1*input;
end;


Function calc_err(t_upr,E,dt:real; n:integer):real; {функция расчёта ошибки}
var
   coord, time: array of real;
   i: integer;
   err,prediction:real;

begin
  setlength(coord,n+2);
  setlength(time,n+2);

for i:=0 to n do
begin
     time[i]:=i*dt;
     coord[i]:=(20+45*time[i])+E;
end;

for i:=0 to n do
begin
     time[i]:=i*dt;
     coord[i]:=(20+45*time[i])+E;
 end;

    prediction:=MNK(coord,time,coord[n+1]+t_upr);
    err:=abs(20+45*(coord[n+1]+t_upr)-prediction);

end;{функция расчёта ошибки}

begin {Главная часть программы}
{Запись в файл}
assign(f,'data.csv');
rewrite(f);
{Запись в файл}

{График 1}
writeln(f,'t_upr');
for i:=0 to 10 do
    begin
        writeln(f,i);
    end;
writeln(f,'err_t_upr');
eps:=DAHOP();
n:=5;
dt:=1.0;
for i:=0 to 10 do
    begin
        writeln(f,calc_err(i,eps,dt, n));
    end;
{График 1}

{График 2}
writeln(f,'n');
for i:=3 to 15 do
    begin
        writeln(f,i);
    end;
writeln(f,'err_n');
eps:=DAHOP();
t_upr:=10;
dt:=1;
for i:=3 to 15 do
    begin
        writeln(f,calc_err(t_upr,eps,(10-0)/i,i));
    end;
{График 2}

{График 3}
n:=5;
t_upr:=10;
dt:=1;
writeln(f,'eps');
 for i:=3 to 15 do
    begin
        err_arr[i]:=DAHOP();
        writeln(f,err_arr[i]);
    end;
 writeln(f,'err_eps');
 for i:=3 to 15 do
    begin
        err_arr[i]:=DAHOP();
        writeln(f,calc_err(t_upr,err_arr[i],dt,n));
    end;
 {График 3}

{График 4}
n:=5;
t_upr:=4;
eps:=DAHOP();
dt:=0;
writeln(f,'dt');
for i:=3 to 10 do
    begin
        dt:=dt+0.5;
        dt_arr[i]:=dt;
        writeln(f,dt_arr[i]);
    end;
writeln(f,'err_dt');
for i:=3 to 10 do
    begin

        writeln(f,calc_err(t_upr,eps,dt_arr[i],n));
    end;
{График 4}
close(f);
end.                                
