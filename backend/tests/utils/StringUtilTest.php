<?php

namespace backend\tests\utils;
use backend\utils\StringUtil;
use PHPUnit\Framework\TestCase;

/**
 * Class StringUtilTest
 * @author Neil.zhou
 */
class StringUtilTest extends TestCase
{
    /**
     * @dataProvider dataProvider
     * @return void
     */
    public function testLineToHump($source, $target)
    {
        $this->assertEquals(StringUtil::lineToHump($source, '-'), $target);
    }
    
    /**
     *
     * @dataProvider dataProvider
     * @return void
     */
    public function testHumpToLine($target, $source)
    {
        $this->assertEquals(StringUtil::humpToLine($source, '-'), $target);
    }
    
    /**
     * undocumented function
     *
     * @return array
     */
    public function dataProvider()
    {
        return [
            ['hello-world', 'HelloWorld'],
            ['hello-world-test', 'HelloWorldTest'],
        ];
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function testOthers()
    {
        $this->assertEquals(
            [1, 2, 3, 4, 5, 6],
            ['1', 2, 3, 4, 5, 6]
        );
    }
    
}
