object SearchFileAgent: TSearchFileAgent
  OldCreateOrder = False
  AllowPause = False
  DisplayName = 'Search File Agent'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  Height = 150
  Width = 215
end
