<?php

use backend\models\AbstractEnumType;
use PHPUnit\Framework\TestCase;

/**
 * Class StringUtilTest
 * @author Neil.zhou
 */
class AbstractEnumTypeTest extends TestCase
{
    /**
     * undocumented function
     *
     * @return void
     */
    public function testGetConstList()
    {
        $stub = new EnumTypeStub('A');
        $this->assertEquals(array('A' => 'A', 'B' => 'B', '__default' => 'B'), $stub->getConstList());
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function testGetValue()
    {
        $stub = new EnumTypeStub('A');
        $this->assertEquals('A', $stub->getValue());
        $stub = new EnumTypeStub();
        
        $this->assertEquals('B', $stub->getValue());
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function testEquals()
    {
        $stub = new EnumTypeStub('B');
        $cmp = new stdClass;
        $this->assertFalse($stub->equals($cmp));
        $stub2 = new EnumTypeStub();
        $this->assertTrue($stub->equals($stub2));
        $stub3 = new EnumTypeStub('A');
        $this->assertFalse($stub->equals($stub3));
    }
    
}


/**
 * Class EnumTypeStub extends AbstractEnumType
 * @author Neil.zhou
 */
class EnumTypeStub extends AbstractEnumType
{
    const A = 'A';
    const B = 'B';
    const __default = 'B';
}
