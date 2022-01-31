Function calc_predict(t_upr,E,dt:real; n:integer):real;
var
   coord, time: array of real;
   i, j: integer;
   solution:array [0..1] of real;
   pred:real;

begin
 setlength(coord,n+2);
  setlength(time,n+2);
 for i:=0 to n do
 begin
     time[i]:=i*dt;
     
     coord[i]:=20+45*i*dt+E;
    
     end;
    MNK(coord,time,solution);
    pred:=x_predict(solution[0],solution[1],n*dt+t_upr));  
end;
