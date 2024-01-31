#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module OAuthClients
  class RedirectUriFromStateService
    def initialize(state:, cookies:)
      @state = state
      @cookies = cookies
    end

    def call
      return ServiceResult.failure if @state.blank?

      redirect_uri = oauth_state_cookie[:href]
      redirect_uri_params = oauth_state_cookie.fetch(:href_params, {})

      if redirect_uri.present? && ::API::V3::Utilities::PathHelper::ApiV3Path::same_origin?(redirect_uri)
        ServiceResult.success(result: { redirect_uri:, redirect_uri_params: })
      else
        ServiceResult.failure
      end
    end

    private

    def oauth_state_cookie
      @oauth_state_cookie ||= load_oauth_state_cookie
    end

    def load_oauth_state_cookie
      return if (cookie = @cookies["oauth_state_#{@state}"]).blank?

      MultiJson.load(cookie, symbolize_keys: true)
    end
  end
end
