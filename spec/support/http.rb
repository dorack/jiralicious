module LoginHelper
  def register_login
    response = %(
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
    })
    FakeWeb.register_uri(:post,
      Jiralicious.uri + "/rest/auth/latest/session",
      :body => response)
  end
end

module JsonResponse
  def issue_json
    File.new(File.expand_path("issue.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def issue_update_json
    File.new(File.expand_path("issue_update.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def issue_2_json
    File.new(File.expand_path("issue_2.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def issue_3_json
    File.new(File.expand_path("issue_update.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def issue_create_json
    File.new(File.expand_path("issue_create.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def issue_createmeta_json
    File.new(File.expand_path("issue_createmeta.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def issue_editmeta_json
    File.new(File.expand_path("issue_editmeta.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def search_json
    File.new(File.expand_path("search.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def transitions_json
    File.new(File.expand_path("transitions.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def comment_json
    File.new(File.expand_path("comment.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def comment_single_json
    File.new(File.expand_path("comment_single.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def projects_json
    File.expand_path("projects.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def project_json
    File.expand_path("project.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def project_componets_json
    File.expand_path("project_componets.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def project_versions_json
    File.expand_path("project_versions.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def project_issue_list_json
    File.expand_path("project_issue_list.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def watchers_json
    File.new(File.expand_path("watchers.json", File.dirname(__FILE__) + "/../fixtures")).read
  end

  def jira_yml
    File.expand_path("jira.yml", File.dirname(__FILE__) + "/../fixtures")
  end

  def user_json
    File.expand_path("user.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def user_array_json
    File.expand_path("user_array.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def user_picker_json
    File.expand_path("user_picker.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def avatar_list_json
    File.expand_path("avatar_list.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def avatar_custom_json
    File.expand_path("avatar_custom.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def avatar_temp_json
    File.expand_path("avatar_temp.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def component_json
    File.expand_path("component.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def component_updated_json
    File.expand_path("component_updated.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def component_ric_json
    File.expand_path("component_ric.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def version_json
    File.expand_path("version.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def version_updated_json
    File.expand_path("version_updated.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def version_ric_json
    File.expand_path("version_ric.json", File.dirname(__FILE__) + "/../fixtures")
  end

  def version_uic_json
    File.expand_path("version_uic.json", File.dirname(__FILE__) + "/../fixtures")
  end
end
