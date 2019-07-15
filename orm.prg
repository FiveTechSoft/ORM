#include "hbclass.ch"
#include "set.ch"

#define HB_DYN_CALLCONV_CDECL       0x0000000  // C default
#define HB_DYN_CTYPE_LONG_UNSIGNED  0x0000014
#define HB_DYN_CTYPE_CHAR_PTR       0x0000101
#define HB_DYN_CTYPE_LONG           0x0000004
#define HB_DYN_CTYPE_INT            0x0000003
#define HB_DYN_CTYPE_LLONG_UNSIGNED 0x0000015
#define NULL                        0x0000000  

#command SELECT <fields,...> [ FROM <cTableName> ] [ INTO <oTable> ]=> ;
            [ <oTable> := ] Orm():Table( <cTableName>, <fields> ) 

static pLib, hMySQL

//----------------------------------------------------------------------------//

function Main()

   local oOrm, oTable

   OrmConnect( "MYSQL", "localhost", "harbour", "password", "dbHarbour", 3306 )
   // OrmConnect()

   // SELECT "*" FROM "users" INTO oTable

   // ? oTable:Count()

return nil

//----------------------------------------------------------------------------//

function OrmConnect( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort )

return Orm():New( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort )

//----------------------------------------------------------------------------//

CLASS Orm

   DATA  cRdbms
   DATA  cServer
   DATA  cUsername
   DATA  cDatabase
   DATA  nPort
   DATA  hConnection 
   DATA  Tables   INIT {}

   METHOD New( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort )

   METHOD Table( cTableName )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort ) CLASS Orm

   hb_default( @cRdbms, RddSetDefault() )
   hb_default( @cServer, Set( _SET_PATH ) )

   ::cRdbms    = cRdbms
   ::cServer   = cServer
   ::cUsername = cUsername
   ::cDatabase = cDatabase
   ::nPort     = nPort

   do case
      case cRdbms == "MYSQL"
         if ! "Windows" $ OS()
            pLib = hb_LibLoad( "/usr/lib/x86_64-linux-gnu/libmysqlclient.so" ) // libmysqlclient.so.20 for mariaDB
         else
            pLib = hb_LibLoad( "libmysql.dll" )
         endif  
         if ! Empty( pLib )
            hMySQL = mysql_init()
            if hMySQL != 0
               ::hConnection = mysql_real_connect( cServer, cUsername, cPassword, cDatabase, nPort )
               Alert( ::hConnection == hMySQL )
            endif   
         endif   
   endcase

return Self

//----------------------------------------------------------------------------//

METHOD Table( cTableName ) CLASS Orm

   local oTable

   if Empty( ::cRdbms )
      ::New()
   endif   

   if ! ::cRdbms $ "MYSQL,MARIADB"
      USE ( cTableName ) VIA ::cRdbms SHARED
      oTable = DbfTable():New( cTableName, Self )
      AAdd( ::Tables, oTable )
   else
   endif

return oTable

//----------------------------------------------------------------------------//

CLASS Table

   DATA  Name
   DATA  Orm

   METHOD New( cTableName, oOrm )

   METHOD Count() VIRTUAL   

ENDCLASS 

//----------------------------------------------------------------------------//

METHOD New( cTableName, oOrm ) CLASS Table

   ::Name = cTableName
   ::Orm  = oOrm

return Self   

//----------------------------------------------------------------------------//

CLASS DbfTable FROM Table

   DATA   cAlias

   METHOD New( cTableName, oOrm )
   METHOD Count() INLINE RecCount()

ENDCLASS      

//----------------------------------------------------------------------------//

METHOD New( cTableName, oOrm ) CLASS DbfTable

   ::Super:New( cTableName, oOrm )
   
   ::cAlias = Alias()

return Self   

//----------------------------------------------------------------------------//

function mysql_init()

return hb_DynCall( { "mysql_init", pLib, hb_bitOr( HB_DYN_CTYPE_LLONG_UNSIGNED, HB_DYN_CALLCONV_CDECL ) }, NULL )

//----------------------------------------------------------------------------//

function mysql_real_connect( cServer, cUserName, cPassword, cDataBaseName, nPort )

   if nPort == nil
      nPort = 3306
   endif   

return hb_DynCall( { "mysql_real_connect", pLib, hb_bitOr( HB_DYN_CTYPE_LLONG_UNSIGNED, HB_DYN_CALLCONV_CDECL ),;
                     HB_DYN_CTYPE_LLONG_UNSIGNED,;
                     HB_DYN_CTYPE_CHAR_PTR, HB_DYN_CTYPE_CHAR_PTR, HB_DYN_CTYPE_CHAR_PTR, HB_DYN_CTYPE_CHAR_PTR,;
                     HB_DYN_CTYPE_LONG, HB_DYN_CTYPE_LONG, HB_DYN_CTYPE_LONG },;
                     hMySQL, cServer, cUserName, cPassword, cDataBaseName, nPort, 0, 0 )

//----------------------------------------------------------------------------//