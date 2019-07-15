#include "hbclass.ch"
#include "set.ch"

#command SELECT <fields,...> [ FROM <cTableName> ] [ INTO <oTable> ]=> ;
            [ <oTable> := ] Orm():Table( <cTableName>, <fields> ) 

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

METHOD New( cRdbms, cServer ) CLASS Orm

   hb_default( @cRdbms, RddSetDefault() )
   hb_default( @cServer, Set( _SET_PATH ) )

   ::cRdbms  = cRdbms
   ::cServer = cServer

return Self

METHOD Table( cTableName ) CLASS Orm

   local oTable

   if Empty( ::cRdbms )
      ::New()
   endif   

   if ! ::cRdbms $ "MYSQL,MARIADB"
      USE ( cTableName ) VIA ::cRdbms
      oTable = DbfTable():New( cTableName, Self )
      AAdd( ::Tables, oTable )
   else
   endif

return oTable

CLASS Table

   DATA  Name
   DATA  Orm

   METHOD New( cTableName, oOrm )

   METHOD Count() VIRTUAL   

ENDCLASS 

METHOD New( cTableName, oOrm ) CLASS Table

   ::Name = cTableName
   ::Orm  = oOrm

return Self   

CLASS DbfTable FROM Table

   DATA   cAlias

   METHOD New( cTableName, oOrm )
   METHOD Count() INLINE RecCount()

ENDCLASS      

METHOD New( cTableName, oOrm ) CLASS DbfTable

   ::Super:New( cTableName, oOrm )
   
   ::cAlias = Alias()

return Self   