class SitesController < ApplicationController
  # GET /sites
  def show
    @site = {}
    render json: @site, status: :ok
  end

  # DELETE /sites
  def destroy
    if NetTester.running?
      NetTester.kill
      FileUtils.rm_r(NetTester.log_dir)
      FileUtils.rm_r(NetTester.pid_dir)
      FileUtils.rm_r(NetTester.socket_dir)
      FileUtils.rm_r(NetTester.process_dir)
      FileUtils.rm_r(NetTester.testlet_dir)
      system('sudo rm -rf /etc/netns/*')
      system("kill -9 `ps aux | grep trema | grep -v grep | awk '{print $2}'`")
    end
  end
end
