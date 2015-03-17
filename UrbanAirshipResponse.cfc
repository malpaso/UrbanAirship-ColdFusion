component name="UrbanAirshipResponse" accessors="true" output="false" hint="A container object for UrbanAirship API responses" {

  property type="any" name="httpObject" default="" getter=true setter=true;
  property type="any" name="response" default="" getter=true setter=true;

  public any function init( required any response, responseFormat="json" ){

    setHttpObject(arguments.response);

    setResponse( toString(body()) );

    return this;
  }

  public any function headers(){
    return getHttpObject().responseHeader;
  }

  public any function body(){
    return getHttpObject().fileContent;
  }

  public any function statusCode(){
    return getHttpObject().statusCode;
  }

  public any function fromJson(){
    return deserializeJSON(getResponse());
  }

  // error handling

  public boolean function hasErrors(){
    if( val(listFirst(getHttpObject().statusCode, " ")) gte 300 ){
      return true;
    }
    return false;
  }

  public any function getError(){
    var error = {};
    if( hasErrors() ){
      error = fromJson(body());
    }
    return error;
  }

}