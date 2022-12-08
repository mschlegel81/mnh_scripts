unit vectorTypes;

{$mode objfpc}{$H+}

interface
TYPE
  Matrix3x3=array[0..8] of double;
  Vector3=array[0..2] of double;
  Vector4=array[0..3] of double;
  SampledNode   =record phi:Vector4; err:Vector3; end;
  SampledSimplex=array of SampledNode;

CONST
  SIMPLEX_NODE:array[0..4] of Vector4=(
   (-0.79056942289451027,-0.45643546912123256,-0.32274858340019369,-0.25),
   ( 0.79056942289451027,-0.45643546912123256,-0.32274858340019369,-0.25),
   ( 0.0                , 0.9128709382424651 ,-0.32274858340019369,-0.25),
   ( 0.0                , 0.0                , 0.9682457502005812 ,-0.25),
   ( 0.0                , 0.0                , 0.0                , 1   ));

OPERATOR * (CONST x,y:Matrix3x3):Matrix3x3;
OPERATOR :=(CONST m:Matrix3x3):Vector3;
OPERATOR +(CONST x,y:Vector3):Vector3;
OPERATOR +(CONST x,y:Vector4):Vector4;
OPERATOR -(CONST x,y:Vector3):Vector3;
OPERATOR -(CONST x,y:Vector4):Vector4;
OPERATOR *(CONST x:Vector3; CONST y:double):Vector3;
OPERATOR *(CONST x:Vector4; CONST y:double):Vector4;
OPERATOR *(CONST x,y:Vector3):double;
OPERATOR *(CONST x,y:Vector4):double;
FUNCTION rx(CONST alpha:double):Matrix3x3;
FUNCTION rz(CONST alpha:double):Matrix3x3;
FUNCTION cross(CONST x,y,z:Vector4):Vector4;
function vector4Of(CONST a,b,c,d:double): Vector4;
PROCEDURE printVector4(CONST v:Vector4);
FUNCTION euklideanDist(CONST x,y:Vector4):double;

implementation
OPERATOR * (CONST x,y:Matrix3x3):Matrix3x3;
  begin
    result[0]:=x[0]*y[0]+x[1]*y[3]+x[2]*y[6];
    result[1]:=x[0]*y[1]+x[1]*y[4]+x[2]*y[7];
    result[2]:=x[0]*y[2]+x[1]*y[5]+x[2]*y[8];
    result[3]:=x[3]*y[0]+x[4]*y[3]+x[5]*y[6];
    result[4]:=x[3]*y[1]+x[4]*y[4]+x[5]*y[7];
    result[5]:=x[3]*y[2]+x[4]*y[5]+x[5]*y[8];
    result[6]:=x[6]*y[0]+x[7]*y[3]+x[8]*y[6];
    result[7]:=x[6]*y[1]+x[7]*y[4]+x[8]*y[7];
    result[8]:=x[6]*y[2]+x[7]*y[5]+x[8]*y[8];
  end;

OPERATOR :=(CONST m:Matrix3x3):Vector3;
  begin
    result[0]:=m[0];
    result[1]:=m[3];
    result[2]:=m[6];
  end;

OPERATOR +(CONST x,y:Vector3):Vector3;
  begin
    result[0]:=x[0]+y[0];
    result[1]:=x[1]+y[1];
    result[2]:=x[2]+y[2];
  end;

OPERATOR +(CONST x,y:Vector4):Vector4;
  begin
    result[0]:=x[0]+y[0];
    result[1]:=x[1]+y[1];
    result[2]:=x[2]+y[2];
    result[3]:=x[3]+y[3];
  end;

OPERATOR -(CONST x,y:Vector3):Vector3;
  begin
    result[0]:=x[0]-y[0];
    result[1]:=x[1]-y[1];
    result[2]:=x[2]-y[2];
  end;

OPERATOR -(CONST x,y:Vector4):Vector4;
  begin
    result[0]:=x[0]-y[0];
    result[1]:=x[1]-y[1];
    result[2]:=x[2]-y[2];
    result[3]:=x[3]-y[3];
  end;

OPERATOR *(CONST x:Vector3; CONST y:double):Vector3;
  begin
    result[0]:=x[0]*y;
    result[1]:=x[1]*y;
    result[2]:=x[2]*y;
  end;

OPERATOR *(CONST x:Vector4; CONST y:double):Vector4;
  begin
    result[0]:=x[0]*y;
    result[1]:=x[1]*y;
    result[2]:=x[2]*y;
    result[3]:=x[3]*y;
  end;

OPERATOR *(CONST x,y:Vector3):double;
  begin
    result:=x[0]*y[0]+x[1]*y[1]+x[2]*y[2];
  end;

OPERATOR *(CONST x,y:Vector4):double;
  begin
    result:=x[0]*y[0]+x[1]*y[1]+x[2]*y[2]+x[3]*y[3];
  end;

FUNCTION rx(CONST alpha:double):Matrix3x3;
  begin
    result[0]:=1;
    result[1]:=0;
    result[2]:=0;
    result[3]:=0;
    result[4]:=cos(alpha);
    result[5]:=-sin(alpha);
    result[6]:=0;
    result[7]:=-result[5];
    result[8]:=result[4];
  end;

FUNCTION rz(CONST alpha:double):Matrix3x3;
  begin
    result[0]:=cos(alpha);
    result[1]:=-sin(alpha);
    result[2]:=0;
    result[3]:=-result[1];
    result[4]:=result[0];
    result[5]:=0;
    result[6]:=0;
    result[7]:=0;
    result[8]:=1;
  end;

FUNCTION cross(CONST x,y,z:Vector4):Vector4;
  begin
    result[0]:= (x[1]*(y[2]*z[3]-y[3]*z[2])-x[2]*(y[1]*z[3]-y[3]*z[1])+x[3]*(y[1]*z[2]-y[2]*z[1]));
    result[1]:=-(x[0]*(y[2]*z[3]-y[3]*z[2])-x[2]*(y[0]*z[3]-y[3]*z[0])+x[3]*(y[0]*z[2]-y[2]*z[0]));
    result[2]:= (x[0]*(y[1]*z[3]-y[3]*z[1])-x[1]*(y[0]*z[3]-y[3]*z[0])+x[3]*(y[0]*z[1]-y[1]*z[0]));
    result[3]:=-(x[0]*(y[1]*z[2]-y[2]*z[1])-x[1]*(y[0]*z[2]-y[2]*z[0])+x[2]*(y[0]*z[1]-y[1]*z[0]));
  end;

function vector4Of(CONST a,b,c,d:double): Vector4;
  begin
    result[0]:=a;
    result[1]:=b;
    result[2]:=c;
    result[3]:=d;
  end;

FUNCTION euklideanDist(CONST x,y:Vector4):double;
  begin
    result:=sqrt(sqr(x[0]-y[0])+
                 sqr(x[1]-y[1])+
                 sqr(x[2]-y[2])+
                 sqr(x[3]-y[3]));
  end;

PROCEDURE printVector4(CONST v:Vector4);
  begin
    writeln('[',v[0],',',v[1],',',v[2],',',v[3],']');
  end;

end.

