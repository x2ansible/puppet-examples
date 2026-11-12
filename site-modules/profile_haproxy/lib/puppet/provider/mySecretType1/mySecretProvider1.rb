Puppet::Type.type(:mySecretType1).provide(:mySecretProvider1) do
  desc "Registers servers in the Enterprise Scheduler platform via the proprietary schedulerctl CLI"

  SCHEDULERCTL = '/usr/local/bin/schedulerctl'

  def scheduler_available?
    File.executable?(SCHEDULERCTL)
  end

  # Without the proprietary CLI there is nothing to register against, so the
  # server is treated as already registered and the resource is a no-op.
  def exists?
    return true unless scheduler_available?
    system(SCHEDULERCTL, 'query', resource[:name])
  end

  def create
    return unless scheduler_available?
    system(SCHEDULERCTL, 'register', resource[:name], '--schedule', resource[:schedule]) or raise "Failed to register #{resource[:name]}"
  end

  def destroy
    return unless scheduler_available?
    system(SCHEDULERCTL, 'unregister', resource[:name]) or raise "Failed to unregister #{resource[:name]}"
  end
end
