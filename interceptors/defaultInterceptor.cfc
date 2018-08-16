component accessors="true" {

  property name="print" inject="PrintBuffer";

  //http://commandbox.ortusbooks.com/developing-for-commandbox/injection-dsl
  //https://github.com/Ortus-Solutions/commandbox/blob/master/src/cfml/system/Shell.cfc

  /**
  * http://commandbox.ortusbooks.com/developing-for-commandbox/interceptors/core-interception-points/server-lifecycle#onserverstart
  * @hint Checks for extensions in config folder; if found, migrates them to Lucee Server's /deploy
  */
  function onServerStart( interceptData ) {
    print.line().line( "[INFO]: .lex Installation module intercepted onServerStart()." ).toConsole();
    var installDetails = interceptData.installDetails;
    //shell.printString( installDetails );

    //only run for Lucee
    if ( installDetails.enginename != 'lucee' ) {
      print.line( "[INFO]: CFEngine not Lucee. Exiting module." ).toConsole();
      return;
    }

    var extensionDirectory = '/config/extensions';
    print.line( "[INFO]: Set extension source directory: #extensionDirectory#" ).toConsole();

    //make sure the source exists
    if ( !directoryExists( extensionDirectory ) ) {
      print.line( "[INFO]: Extension source directory did not exist. Exiting module." ).toConsole();
      return;
    }

    var extensions = directoryList( extensionDirectory, false, 'name', '*.lex' );

    //check for actual extensions
    if ( !extensions.len() ) {
      print.line( "[INFO]: No extensions found. Exiting module." ).toConsole();
      return;
    }

    var serverInfo = interceptData.serverInfo;
    var serverHome = serverInfo.serverHome & serverInfo.serverConfigDir;
    var deployDirectory = serverHome & '/lucee-server/deploy';

    print.line( "[INFO]: Set extension deployment directory: #deployDirectory#" ).toConsole();

    //make sure deploy folder exists
    if ( !directoryExists( deployDirectory ) ) {
      directoryCreate( deployDirectory );
      print.line( "[INFO]: Extension deployment directory did not exist, so it was created." ).toConsole();
    }

    print.line( "[INFO]: Starting installation of #extensions.len()# extension#extensions.len() == 1 ? '' : 's'#." ).toConsole();

    for ( var extension in extensions ) {
      fileMove( '#extensionDirectory#/#extension#', '#deployDirectory#/#extension#' );

      print.line( "[INFO]: Extension #extension# was moved to deployment folder." ).toConsole();
    }

    print.line( "[INFO]: Extension installation complete. Exiting module." ).toConsole();
  }

}