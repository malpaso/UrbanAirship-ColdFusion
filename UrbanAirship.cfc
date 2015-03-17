component name="UrbanAirship" output="false" accessors="true" hint="A ColdFusion wrapper for the Urban Airship API" {

  property type="string"  name="service"          default="UrbanAirship"                    getter=true setter=true;
  property type="string"  name="apiKey"           default=""                                getter=true setter=true;
  property type="string"  name="apiSecret"        default=""                                getter=true setter=true;
  property type="string"  name="endPoint"         default="https://go.urbanairship.com/api" getter=true setter=true;
  property type="boolean" name="debugMode"        default=false                             getter=true setter=true;

  public any function init( required struct settings ){

    validateSettings(arguments.settings);

    for( key in arguments.settings ){
      evaluate("set#key#('#arguments.settings[key]#')");
    }

    return this;
  }

  // PUSH

  public any function push(required struct pushObject ){

    var service = createHTTPService("POST");

    service.setUrl( getEndPoint() & '/push');

    service = addBodyParams( service, pushObject );

    return call(service);

  }

  public any function validate_push(required struct pushObject){

    var service = createHTTPService("POST");

    service.setUrl( getEndPoint() & '/push/validate');

    service = addBodyParams( service, pushObject );

    return call(service);

  }

  // TAGS

  public any function list_tags(){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/tags');

    return call(service);

  }

  public any function create_tag(required string tag){

    var service = createHTTPService("PUT");

    service.setUrl( getEndPoint() & '/tags/#tag#');

    return call(service);

  }

  public any function delete_tag(required string tag){

    var service = createHTTPService("DELETE");

    service.setUrl( getEndPoint() & '/tags/#tag#');

    return call(service);

  }

  // DEVICES

  public any function list_device_tokens(){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/device_tokens');

    return call(service);

  }

  public any function list_channels(){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/channels');

    return call(service);

  }

  public any function list_device_pins(){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/device_pins');

    return call(service);

  }

  public any function list_apids(){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/apids');

    return call(service);

  }

  // device registration is primarily handled by the UA SDK's
  public any function create_device(string type="tokens", required any id, struct options){

    // ARGUMENTS: type & id = tokens|pins

    var service = createHTTPService("PUT");

    service.setUrl( getEndPoint() & '/device_#type#/#id#');

    // use to set alias and/or tags upon registration
    if( !structIsEmpty(options) ){
      service = addBodyParams( service, options );
    }

    return call(service);

  }

  public any function delete_device(string type="tokens", required any id){

    // ARGUMENTS: type & id = tokens|pins

    var service = createHTTPService("DELETE");

    service.setUrl( getEndPoint() & '/device_#type#/#id#');

    return call(service);

  }

  public any function channel(required any channel){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/channels/#channel#');

    return call(service);

  }

  public any function device_feedback(required any timestamp){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/device_tokens/feedback/?since=#timestamp#');

    return call(service);

  }

  // SCHEDULES

  public any function create_schedules(required any scheduleObject){

    var service = createHTTPService("POST");

    service.setUrl( getEndPoint() & '/schedules');

    service = addBodyParams( service, scheduleObject );

    return call(service);

  }

  public any function list_schedules(){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/schedules');

    return call(service);

  }

  public any function schedule(required any id){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/schedules/#id#');

    return call(service);

  }

  public any function update_schedule(required any id, required struct scheduleObject){

    var service = createHTTPService("PUT");

    service.setUrl( getEndPoint() & '/schedules/#id#');

    service = addBodyParams( service, scheduleObject );

    return call(service);

  }

  public any function delete_schedule(required any id){

    var service = createHTTPService("DELETE");

    service.setUrl( getEndPoint() & '/schedules/#id#');

    return call(service);

  }

  // SEGMENTS

  public any function list_segments(){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/segments');

    return call(service);

  }

  public any function segment(required any id){

    var service = createHTTPService("GET");

    service.setUrl( getEndPoint() & '/segments/#id#');

    return call(service);

  }

  public any function create_segment(required any segmentObject){

    var service = createHTTPService("POST");

    service.setUrl( getEndPoint() & '/segments');

    service = addBodyParams( service, segmentObject );

    return call(service);

  }

  public any function update_segment(required any id, required struct segmentObject){

    var service = createHTTPService("PUT");

    service.setUrl( getEndPoint() & '/segments/#id#');

    service = addBodyParams( service, segmentObject );

    return call(service);

  }

  // PRIVATE

  private any function call(required any httpService){

    var service = arguments.httpService;
    var result = service.send().getPrefix();

    // debug
    if( getDebugMode() ){
      writeLog(type="information",file=getService(),text=toString(result.fileContent));
    }

    if (NOT isDefined("result.statusCode")) {
      throw(type=getService(),errorcode="#getService()#_unresponsive", message="The #getService()# server did not respond.", detail="The #getService()# server did not respond.");
    }

    if ( val(listFirst(result.statusCode, " ")) gte 300 ){
      throw(type=getService(),errorcode="#listFirst(result.statusCode, ' ')#", message="#result.statusCode#" detail="#result.fileContent.toString()#");
    }

    return createObject("component","UrbanAirshipResponse").init( result );
  }

  private HTTP function createHTTPService(string urlmethod='GET', numeric httptimeout=10) {

    var service = new HTTP();
    service.setMethod(arguments.urlmethod);
    service.setCharset('utf-8');
    service.setTimeout(arguments.httptimeout);
    service.addParam(type="header",name="Accept",value="application/vnd.urbanairship+json; version=3;");
    service.addParam(type="header",name="Content-Type",value="application/json");
    service.addParam(type="header",name="Authorization",value="Basic #getApiKey()#:#getApiSecret()#");

    return service;
  }

  private any function addBodyParams( required any service, required struct params ){
    var s = arguments.service;
    var p = arguments.params;
    var debug = {};

    s.addParam( type="body", value=jsonencode(p) );

    return s;
  }

  private any function addUrlParams( required any service, required struct params, string exclude_list="" ){

    var s = arguments.service;
    var p = arguments.params;
    var e = arguments.exclude_list;

    for( key in p ){
      if( listFindNoCase(e,key) eq 0 AND len(p[key]) gt 0 ){
        s.addParam(
          type="url",
          name=key,
          value=trim(p[key])
        );
      }
    }

    return s;
  }

  private any function buildUrlParams( required struct params, string exclude_list="" ){

    var result = "";
    var p = arguments.params;
    var e = arguments.exclude_list;

    for( key in p ){
      if( listFindNoCase(e,key) eq 0 AND len(p[key]) gt 0 ){
        if( len(result) ){ result += "&"; }
        result += key & "=" & trim(p[key]);
      }
    }

    return result;
  }

  private void function validateSettings(required struct settings){

    if( !struckKeyExists(arguments.settings,"apiKey") ){
      throw(type="error", file="#getService()#", message="[apiKey] not provided", detail="Settings: #toString(serializeJSON(arguments.settings))#");
    }

    if( !struckKeyExists(arguments.settings,"apiSecret") ){
      throw(type="error", file="#getService()#", message="[apiSecret] not provided", detail="Settings: #toString(serializeJSON(arguments.settings))#");
    }

    for( key in arguments.settings ){
      // validate key and secret
      if( listFindNoCase("apiKey,apiSecret",key) gt 0 ){
        if( !len(arguments.settings[key]) ){
          throw(type="error", file="#getService()#", message="[#key#] is empty", detail="Settings: #toString(serializeJSON(arguments.settings))#");
        }
      }
    }

  }

  /**
   * Serialize native ColdFusion objects (simple values, arrays, structures, queries) into JSON format
   * http://json.org/
   * http://jehiah.com/projects/cfjson/
   *
   * @param object Native data to be serialized
   * @return Returns string with serialized data.
   * @author Jehiah Czebotar (jehiah@gmail.com)
   * @version 1.2, August 20, 2005
   */

  private any function jsonencode(arg)
  {
    var i=0;
    var o="";
    var u="";
    var v="";
    var z="";
    var r="";

    if (isarray(arg))
    {
      o="";
      for (i=1;i lte arraylen(arg);i=i+1){
        try{
          v = jsonencode(arg[i]);
          if (o neq ""){
            o = o & ',';
          }
          o = o & v;
        }
        catch(Any ex){
          o=o;
        }
      }
      return '['& o &']';
    }
    if (isstruct(arg))
    {
      o = '';
      if (structisempty(arg)){
        return "{null}";
      }
      z = StructKeyArray(arg);
      for (i=1;i lte arrayLen(z);i=i+1){
        try{
        v = jsonencode(evaluate("arg."&z[i]));
        }catch(Any err){WriteOutput("caught an error when trying to evaluate z[i] where i="& i &" it evals to "  & z[i] );}
        if (o neq ""){
          o = o & ",";
        }
        o = o & '"'& lcase(z[i]) & '":' & v;
      }
      return '{' & o & '}';
    }
    if (isobject(arg)){
      return "unknown";
    }
    if (issimplevalue(arg) and isnumeric(arg)){
      return ToString(arg);
    }
    if (issimplevalue(arg)){
      return '"' & JSStringFormat(ToString(arg)) & '"';
    }
    if (IsQuery(arg)){
      o = o & '"RECORDCOUNT":' & arg.recordcount;
      o = o & ',"COLUMNLIST":'&jsonencode(arg.columnlist);
      // do the data [].column
      o = o & ',"DATA":{';
      // loop through the columns
      for (i=1;i lte listlen(arg.columnlist);i=i+1){
        v = '';
        // loop throw the records
        for (z=1;z lte arg.recordcount;z=z+1){
          if (v neq ""){
            v =v  & ",";
          }
          // encode this cell
          v = v & jsonencode(evaluate("arg." & listgetat(arg.columnlist,i) & "["& z & "]"));
        }
        // put this column in the output
        if (i neq 1){
          o = o & ",";
        }
        o = o & '"' & listgetat(arg.columnlist,i) & '":[' & v & ']';
      }
      // close our data section
      o = o & '}';
      // put the query struct in the output
      return '{' & o & '}';
    }
    return "unknown";
  }

}