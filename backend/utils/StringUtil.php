<?php

namespace backend\utils;

/**
 * Class StringUtil
 * @author Neil.zhou
 */
class StringUtil
{
    /**
     * Parse hump string to separated by some line or charactor and lowercase
     * Usage:
     *   humpToLine('HelloClass') return hello-class
     *   humpToLine('HelloClass', '_') return hello_class
     *
     * @return string     
     */
    public static function humpToLine($str, $separator = '-')
    {
        if (empty($separator) || (!is_string($separator))) {
            $separator = '-';
        }

        return trim(
            preg_replace_callback(
                '/([A-Z]){1}/',
                function($matches) use ($separator) {
                    return $separator . strtolower($matches[0]);
                },
                $str
            ),
            $separator
        );
    }
    
    /**
     * Parse line to Hump
     * Useage:
     *   lineToHump('hello-class') return HelloClass
     *   lineToHump('hello_class', '_') return HelloClass
     *   lineToHump('hello_class-test', '_-') return HelloClassTest
     *
     * @return string
     */
    public static function lineToHump($str, $separator = '-')
    {
        if (empty($separator) || (!is_string($separator))) {
            $separator = '-';
        }
        return ucfirst(preg_replace_callback(
            "/([$separator]+([a-z]{1}))/i",
            function($matches) {
                return strtoupper($matches[2]);
            },
            $str
        ));
    }
    
}

