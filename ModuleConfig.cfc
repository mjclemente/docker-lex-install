component {

  this.title = "CommandBox Docker .lex Install";
  this.author = "Matthew J. Clemente";
  this.description = "Preload Lucee extensions (.lex) into your CommandBox Docker deployments.";

  function configure() {
   //we'll use this interceptor to capture the server start
    interceptors = [
        {
          class = '#moduleMapping#.interceptors.defaultInterceptor'
        }
    ];
  }

}