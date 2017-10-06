<?php
// auto load class in the backend space
spl_autoload_register(function($class_name){

    $file_path = dirname(__DIR__) . DIRECTORY_SEPARATOR . str_replace('\\', DIRECTORY_SEPARATOR, $class_name) . '.php';
    if (is_file($file_path)) {
        include_once $file_path;
    }
});
