#include "hbclass.ch"
#include "set.ch"

#command SELECT <fields,...> [ FROM <cTableName> ] [ INTO oTable ]=> ;
            oTable := Orm():Table( <cTableName>, <fields> ) 

function Main()

   local oTable

   SELECT "*" FROM "users" INTO oTable

   ? oTable:Count()

return nil

function OrmConnect( cRdbms, cServer )

return Orm():New( cRdbms, cUrlPath )

CLASS Orm

   DATA  cRdbms
   DATA  cServer
   DATA  Tables   INIT {}

   METHOD New( cRdbms, cServer )

   METHOD Table( cTableName )

ENDCLASS

METHOD New( cRdms, cServer ) CLASS Orm

   hb_default( @cRdbms, RddName() )
   hb_default( @cServer, Set( _SET_PATH ) )

   ::cRdbms  = cRdbms
   ::cServer = cServer

return Self

METHOD Table( cTableName ) CLASS Orm

   if ! ::cRdbms $ "MYSQL,MARIADB"
      USE ( cTableName ) VIA ::cRdbms
   else
   endif

return oTable

CLASS Table

   DATA  cName
   DATA  Orm

ENDCLASS 