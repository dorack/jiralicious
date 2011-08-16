module LoginHelper
  def register_login
    response = %Q|
    {
      "session": {
      "name": "JSESSIONID",
      "value": "12345678901234567890"
    },
      "loginInfo": {
        "failedLoginCount": 10,
        "loginCount": 127,
        "lastFailedLoginTime": "2011-07-25T06:31:07.556-0500",
        "previousLoginTime": "2011-07-25T06:31:07.556-0500"
      }
    }|
    FakeWeb.register_uri(:post,
                         Jiralicious.uri + '/rest/auth/latest/session',
                         :body => response)
  end
end

module JsonResponse
  def issue_json
    File.new(File.expand_path('issue.json', File.dirname(__FILE__) + '/../fixtures')).read
  end
end
