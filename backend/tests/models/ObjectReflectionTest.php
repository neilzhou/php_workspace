<?php

use backend\models\ObjectReflection;
use PHPUnit\Framework\TestCase;

/**
 * Class ObjectReflectionTest
 * @author Neil.zhou
 */
class ObjectReflectionTest extends TestCase
{
    protected $stub;
    protected $sub_stub;
    /**
     * undocumented function
     *
     * @return void
     */
    public function setUp()
    {
        $this->stub = new ObjectReflectionStub();
        $this->sub_stub = new ObjectReflectionSubStub();
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function testGet_accessible_vars()
    {
        $this->assertEquals(array(
            'pub' => 'public',
            'other' => 'other'
        ), $this->stub->get_accessible_vars());

        $this->assertEquals(
            array(
                'pub' => 'public',
                'other' => 'other',
                'pub2' => 'sub_pub'
            ),
            $this->sub_stub->get_accessible_vars()
        );
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function test_get_obj_vars()
    {
        $this->assertEquals(array(
            'pub' => 'public',
            'other' => 'other', 
            'pro' => null, 
            // 'pri' => 'pri', // no pri
        ), $this->stub->get_obj_vars());

        $this->assertEquals(array(
            'pub' => 'public',
            'other' => 'other', 
            'pro' => 'sub_pro', 
            'pub2' => 'sub_pub', 
            // 'pri' => 'pri', // no pri
        ), $this->sub_stub->get_obj_vars());
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function test_all_vars()
    {
        $this->assertEquals(array(
            'pri' => 'private', 
            'pub' => 'public',
            'pro' => null, 
            'other' => 'other', 
            's_pri' => null, 
            's_pro' => null, 
            's_pub' => 's_pub', 
        ), $this->stub->get_all_vars());

        $this->assertEquals(array(
            'pri2' => 'sub_pri2', 
            'pub' => 'public',
            'pub2' => 'sub_pub', 
            'pro' => 'sub_pro', 
            'other' => 'other', 
            's_pro' => null, 
            's_pub' => 's_sub_pub', 
        ), $this->sub_stub->get_all_vars());
    }

    /**
     * undocumented function
     *
     * @return void
     */
    public function test_get_public_vars()
    {
        $this->assertEquals(array(
            'pub' => 'public',
            'other' => 'other', 
            's_pub' => 's_pub', 
        ), $this->stub->get_public_vars());

        $this->assertEquals(array(
            'pub' => 'public',
            'other' => 'other', 
            'pub2' => 'sub_pub', 
            's_pub' => 's_sub_pub', 
        ), $this->sub_stub->get_public_vars());
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function test_get_protected_vars()
    {
        $this->assertEquals(array(
            'pro' => null, 
            's_pro' => null, 
        ), $this->stub->get_protected_vars());

        $this->assertEquals(array(
            'pro' => 'sub_pro', 
            's_pro' => null
        ), $this->sub_stub->get_protected_vars());
    }

    /**
     * undocumented function
     *
     * @return void
     */
    public function test_get_private_vars()
    {
        $this->assertEquals(array(
            'pri' => 'private', 
            's_pri' => null, 
        ), $this->stub->get_private_vars());
        $this->assertEquals(array(
            'pri2' => 'sub_pri2'
        ), $this->sub_stub->get_private_vars());
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function test_get_static_vars()
    {
        $this->assertEquals(array(
            's_pri' => null, 
            's_pro' => null, 
            's_pub' => 's_pub', 
        ), $this->stub->get_static_vars());

        $this->assertEquals(array(
            's_pro' => null, 
            's_pub' => 's_sub_pub', 
        ), $this->sub_stub->get_static_vars());
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function test_get_public_vars_without_static()
    {
        $this->assertEquals(array(
            'pub' => 'public',
            'other' => 'other', 
            //'s_pub' => 's_pub', 
        ), $this->stub->get_public_vars_without_static());


        $this->assertEquals(array(
            'pub' => 'public',
            'other' => 'other', 
            'pub2' => 'sub_pub', 
            //'s_pub' => 's_sub_pub', 
        ), $this->sub_stub->get_public_vars_without_static());
    }
    
}


/**
 * Class ObjectReflection
 * @author Neil.zhou
 */
class ObjectReflectionStub extends ObjectReflection
{
    public $pub;
    protected $pro;
    private $pri;
    public static $s_pub = 's_pub';
    protected static $s_pro;
    private static $s_pri;

    const CONS = 'CONSTANT';

    function __construct()
    {
        $this->pub = 'public';
        $this->pri = 'private';
        $this->other = 'other';
    }
}


class ObjectReflectionSubStub extends ObjectReflectionStub
{
    public static $s_pub = 's_sub_pub';
    private $pri2 = 'sub_pri2';
    protected $pro = 'sub_pro';
    public $pub2 = 'sub_pub';
}
