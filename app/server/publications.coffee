ReactiveTable.publish "administratedSurveys", @Surveys, ->
  if @userId
    {
      createdBy: @userId
    }
  else
    {
      # TODO: Add this line when accounts are added so no results are shown to unauthenticated users.
      # createdBy: "nobody"
    }
