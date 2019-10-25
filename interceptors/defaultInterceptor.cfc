component accessors="true" {

  //http://commandbox.ortusbooks.com/developing-for-commandbox/injection-dsl
  //https://github.com/Ortus-Solutions/commandbox/blob/master/src/cfml/system/Shell.cfc

  /**
  * http://commandbox.ortusbooks.com/developing-for-commandbox/interceptors/core-interception-points/server-lifecycle#onserverstart
  * @hint Checks for extensions in config folder; if found, migrates them to Lucee Server's /deploy
  */
  function onServerStart( interceptData ) {
    var print = wirebox.getInstance( "PrintBuffer" );
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

    var deployDirectory = returnDeployDirectory( interceptData.serverInfo );

    print.line( "[INFO]: Set extension deployment directory: #deployDirectory#" ).toConsole();

    //make sure deploy folder exists
    if ( !directoryExists( deployDirectory ) ) {
      directoryCreate( deployDirectory );
      print.line( "[INFO]: Extension deployment directory did not exist, so it was created." ).toConsole();
    }

    print.line( "[INFO]: Starting installation of #extensions.len()# extension#extensions.len() == 1 ? '' : 's'#." ).toConsole();

    for ( var extension in extensions ) {
      var srcLex = '#extensionDirectory#/#extension#';
      var destLex = '#deployDirectory#/#extension#';
      fileMove( srcLex, destLex );
      print.line( "[INFO]: Extension #extension# was moved to deployment folder." ).toConsole();
    }

    if( installDetails.initialInstall ) {
      print.line( "******************************************" ).toConsole();
      print.line( "[INFO]: This is the first server start." ).toConsole();
      print.line( "[INFO]: To ensure extensions are loaded, please complete a warmup cycle of the server." ).toConsole();
      print.line( "******************************************" ).toConsole();
    }

    print.line( "[INFO]: Extension deployment complete. Resuming server start." ).toConsole();
  }


  /**
  * @hint When the warmup is completed, this confirms that the extensions have been deployed, prior to finishing shut down
  */
  function onServerStop( interceptData ) {
    var print = wirebox.getInstance( "PrintBuffer" );
    print.line().line( "[INFO]: .lex Installation module intercepted onServerStop()." ).toConsole();

    var deployDirectory = returnDeployDirectory( interceptData.serverInfo );
    print.line( "[INFO]: Extension deployment directory: #deployDirectory#" ).toConsole();

    var extensions = directoryList( deployDirectory, false, 'name', '*.lex' );

    if( extensions.len() ) {
      print.line( "[INFO]: Extensions found. Delaying server stop." ).toConsole();
      print.line( "[INFO]: Waiting on deployment of #extensions.len()# extension#extensions.len() == 1 ? '' : 's'#." ).toConsole();

      for ( var extension in extensions ) {
        var destLex = '#deployDirectory#/#extension#';
        while( fileExists( destLex ) ) {
            print.line( "[INFO]: Waiting for #extension# to be deployed..." ).toConsole();
            sleep( 3000 );
          }
        print.line( "[INFO]: Extension #extension# has been deployed!" ).toConsole();
      }
      sleep( 3000 );
    }

    print.line( "[INFO]: No remaining extensions to deploy. Resuming server stop." ).toConsole();
  }

  private function returnDeployDirectory( serverInfo ) {
    var serverHome = serverInfo.serverHome & serverInfo.serverConfigDir;
    return serverHome & '/lucee-server/deploy';
  }

}