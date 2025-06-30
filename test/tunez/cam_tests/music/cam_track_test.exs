defmodule TunezWeb.Music.CamTrackTest do
  use Tunez.DataCase, async: false

  @moduletag :capture_log

  describe desc(:iex) do
    test desc(:create_album_tracks) do
      %{tracks: tracks} = build(:album, insert?: true)
      refute Enum.empty?(tracks)

      tracks
      |> Enum.each(fn track ->
        assert track.order
        assert track.name
        assert track.duration_seconds
      end)
    end
  end
end
