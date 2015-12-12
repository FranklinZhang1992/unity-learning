#=====================================================================================
#
#  Copyright (c) 2007-2008 Stratus Technologies Bermuda Ltd.  All rights reserved
#  Confidential and proprietary.
#
#  No part of this page may be used, re-distributed, copied, re-published or
#  re-written without prior express written consent
#
#=====================================================================================

require 'hoard'

class Module
    def artifact_allocatable
        artifact

        # private allocation tag management
        property :allocation_tag
        define_method('allocation_tag_update') {
            return if hoard.nil?
            hoard.free_cache_update(self)
        }
        define_method('allocation_tag_setter_hook') { allocation_tag_update }
        define_method('allocation_tag_load_hook')   { allocation_tag_update }
    end

end
class HoardPool < Hoard
    def initialize(controller, name, factory, free_chooser_lambda=nil)
        @free_cache = Set.new  # Cache free values for fast atomic allocation
        @free_cache_lock = Monitor.new
        @free_chooser_lambda = free_chooser_lambda
        @free_chooser_lambda ||= lambda do |pool, free_uuid_set|
            # Default choosing function takes first free thing out of the free pool
            free_uuid_set.detect {|o| true}   # .first method is unimplemented for Set - this is identical
        end
        super(controller, name, factory)
    end

    # Allocate a resource, and mark it with the user-specified allocation tag.
    # Failed allocation returns nil, otherwise the allocated object is returned.
    def allocate(tag)
        object = nil
        @free_cache_lock.synchronize {
            loop do
                if @free_cache.empty?
                    # Ideally, the free cache would be reliable and we could just return nil,
                    #   but hoard properties on a new, foreign object appear asynchonously.
                    free_cache_refresh
                end
                if @free_cache.empty?
                    # After double checking, there really are no free objects, so return nil
                    return nil
                end
                object_uuid = @free_chooser_lambda.call(self, @free_cache)
                object = self[object_uuid]
                __free_cache_update__(object)
                if object.allocation_tag.nil?
                    # This object is really free, so allocate it
                    break
                end
            end
            object.allocation_tag = tag.to_s
        }

        # XXX jrd - ideally, we would make sure the property is fully synced to our peers before returning the value
        #object.allocation_tag_sync

        object
    end

    # Reserve a specific object with the given tag.
    # If the object is already reserved, then the method fails, and will not reserve the object.
    # The return value is the tag of the currently held reservation (nil == success, String == failure)
    def reserve(object, tag)
        @free_cache_lock.synchronize {
            return object.allocation_tag if object.allocation_tag
            object.allocation_tag = tag.to_s
        }
        nil
    end

    # Free a resource that was allocated with the given tag
    def free(object, tag)
        return unless object.hoard == self  # Paranoid???
        return unless object.allocation_tag == tag.to_s
        object.allocation_tag = nil
    end


    # Free Cache Management (logically private)
    def free_cache_refresh
        @free_cache_lock.synchronize {
            each { |object| __free_cache_update__(object) }
        }
    end
    def free_cache_update(object)
        @free_cache_lock.synchronize { __free_cache_update__(object) }
    end
    def __free_cache_update__(object)
        if object.allocation_tag.nil? and object.is_complete?
            @free_cache.add(object.uuid)
        else
            @free_cache.delete(object.uuid)
        end
    end


    # Hoard methods that need their behavior tweaked to support an allocation pool
    def add(object)
        [ :allocation_tag ].each do |symbol|
            object.respond_to? symbol or
                raise TypeError, "must respond to #{symbol.to_s} to be managed by this hoard pool (did you run artifact_allocatable() in your class definition?)"
        end
        retval = super
        free_cache_update(object)
        retval
    end
    def delete(object)
        @free_cache_lock.synchronize { @free_cache.delete(object.uuid) }
        super
    end
    def load
        super
        free_cache_refresh
    end
    def refresh
        super
        free_cache_refresh
    end
end
