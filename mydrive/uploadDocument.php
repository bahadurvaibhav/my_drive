<?php

$MAXIMUM_FILE_SIZE_ALLOWED_MB = 2;
define ('SITE_ROOT', realpath(dirname(__FILE__)));

$d = $_POST;
$file = $_FILES['file'];
$fileName = $file['name'];
$fileTmpName = $file['tmp_name'];
$fileSize = $file['size'];
$fileError = $file['error'];
$fileType = $file['type'];

$fileExt = explode('.', $fileName);
$fileActualExt = strtolower(end($fileExt));
$allowed = array('jpg', 'jpeg', 'png', 'pdf');
if (in_array($fileActualExt, $allowed)) {
  if ($fileError === 0) {
    if ($fileSize < $MAXIMUM_FILE_SIZE_ALLOWED_MB * 1000000) {
      $fileDestination = SITE_ROOT . "\\" . $fileName;
	  move_uploaded_file($fileTmpName, $fileDestination);
      echo json_encode(array('status' => 200, 'msg' => "Upload Document successful"));
    } else {
      echo json_encode(array('status' => 201, 'msg' => 'File size bigger than '.$MAXIMUM_FILE_SIZE_ALLOWED_MB.' MB'));
    }
  } else {
    echo json_encode(array('status' => 203, 'msg' => 'Error uploading file with code: ' . $fileError));
  }
} else {
  echo json_encode(array('status' => 202, 'msg' => 'File type not allowed. Only jpg, jpeg, png, pdf allowed'));
}
