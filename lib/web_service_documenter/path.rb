module WebServiceDocumenter
  module Path
    # path - normalized for Service or ServiceCollection
    def path
      @path ||= 
        # remove {} - e.g. {id} => id
        p = self.endpoint.gsub(/(\{|\})/,"")
        # remove .format
        p = p.gsub(/\.(\w+)/,'')
        # remove trailing slash and leading slash
        p = p.gsub(/\/$/,'').gsub(/^\//,'')
        # add .html
        p + ".html"
    end
  end
end