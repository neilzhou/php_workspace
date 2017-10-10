<?php

namespace backend\models;

/**
 * Class ObjectReflection
 * @author Neil.zhou
 */
class ObjectReflection
{
    /**
     * undocumented function
     *
     * @return void
     */
    public function get_accessible_vars()
    {
        return call_user_func('get_object_vars', $this);
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function get_obj_vars()
    {
        return get_object_vars($this);
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function get_public_vars()
    {
        return $this->get_reflection_vars(\ReflectionProperty::IS_PUBLIC);
    }

    /**
     * undocumented function
     *
     * @return void
     */
    public function get_public_vars_without_static()
    {

            $r = $this->get_reflection_obj();
            $vars = $r->getProperties(\ReflectionProperty::IS_PUBLIC);
            foreach ($vars as $key => $var) {
                if ($var->isStatic()) {
                    unset($vars[$key]);
                }
            }
        return $this->reflection_prop_to_array($vars);
    }
    
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function get_protected_vars()
    {
        return $this->get_reflection_vars(\ReflectionProperty::IS_PROTECTED);
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function get_private_vars()
    {
        return $this->get_reflection_vars(\ReflectionProperty::IS_PRIVATE);
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function get_static_vars()
    {
        return $this->get_reflection_vars(\ReflectionProperty::IS_STATIC);
    }
    
    /**
     * undocumented function
     *
     * @return void
     */
    public function get_all_vars()
    {
        return $this->get_reflection_vars();
    }

    protected function get_reflection_vars($filter = false) 
    {
            $r = $this->get_reflection_obj();
        if ($filter === false) {
            $vars = $r->getProperties();
        } else {
            $vars = $r->getProperties($filter);
        }
        return $this->reflection_prop_to_array($vars);
    }
    
    protected function get_reflection_obj()
    {
        return new \ReflectionObject($this);
    }

    protected function reflection_prop_to_array($properties)
    {
        $result = array();
        foreach ($properties as $prop) {
            $prop->setAccessible(true);
            $result[$prop->getName()] = $prop->getValue($this);
        }
        return $result;
    }
}
