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
        $this->assertEquals(array('A' => 'A', 'B' => 'B', '__default' => 'A'), $stub->getConstList());
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
    const __default = 'A';
}
