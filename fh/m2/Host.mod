MODULE Host ;

FROM StrIO IMPORT WriteString, WriteLn ;
FROM NumberIO IMPORT WriteInt ;
FROM CKernel IMPORT HostCommit, HostLastCode ;

BEGIN
  IF HostCommit (0, 3, 0, 2, 2, 0, 4, 4, 1, 5,
                 0, 2, 0, 2, 2, 0, 4, 4, 1, 5,
                 0, 7, 1179800404, 1) = 1
  THEN
    WriteString ("commit-true")
  ELSE
    WriteString ("commit-false")
  END ;
  WriteString (" code ") ;
  WriteInt (HostLastCode (), 0) ;
  WriteLn ;
  IF HostCommit (0, 3, 0, 2, 2, 0, 4, 4, 1, 5,
                 0, 2, 0, 2, 2, 0, 4, 4, 1, 5,
                 0, 7, 1, 1) = 0
  THEN
    WriteString ("unauth-false")
  ELSE
    WriteString ("unauth-true")
  END ;
  WriteLn
END Host.
