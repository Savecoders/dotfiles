
from libqtile import bar, widget
from libqtile.config import Screen
from .theme import colors

screens = [

    Screen(
        top=bar.Bar(
            [
                widget.Spacer(length=20,
                              background=colors['dark'],
                              ),

                widget.Image(
                    filename='~/.config/qtile/assets/launch_Icon.png',
                    margin=2,
                    background=colors['dark'],
                ),

                widget.TextBox(
                    text="",
                    font="SF Pro Display Bold",
                    fontsize=30,
                    padding=0,
                    foreground=colors['dark'],
                    background=colors['grey'],
                ),

                widget.GroupBox(
                    fontsize=16,
                    borderwidth=3,
                    highlight_method='block',
                    active=colors['active'],
                    block_highlight_text_color=colors['focus'],
                    highlight_color=colors['grey'],
                    inactive=colors['inactive'],
                    foreground=colors['grey'],
                    background=colors['grey'],
                    this_current_screen_border=colors['dark'],
                    this_screen_border=colors['dark'],
                    other_current_screen_border=colors['dark'],
                    other_screen_border=colors['dark'],
                    urgent_border=colors['dark'],
                    rounded=True,
                    disable_drag=True,
                ),

                widget.TextBox(
                    text="",
                    font="SF Pro Display Bold",
                    fontsize=30,
                    padding=0,
                    foreground=colors['grey'],
                    background=colors['focus'],
                ),

                widget.CurrentLayoutIcon(
                    background=colors['focus'],
                    padding=0,
                    scale=0.5,
                ),

                widget.CurrentLayout(
                    background=colors['focus'],
                    font='SF Pro Display Bold',
                ),

                widget.TextBox(
                    text="",
                    font="SF Pro Display Bold",
                    fontsize=30,
                    padding=0,
                    foreground=colors['focus'],
                    background=colors['color3'],
                ),

                widget.WindowName(
                    background=colors['color3'],
                    format="{name}",
                    font='SF Pro Display Bold',
                    empty_group_string='Desktop',
                ),


                widget.TextBox(
                    text="",
                    font="SF Pro Display Bold",
                    fontsize=30,
                    padding=0,
                    foreground=colors['focus'],
                    background=colors['color3'],
                ),

                widget.Systray(
                    background=colors['focus'],
                    fontsize=2,
                ),

                widget.TextBox(
                    text=' ',
                    background=colors['focus'],
                ),

                widget.TextBox(
                    text="",
                    font="SF Pro Display Bold",
                    fontsize=30,
                    padding=0,
                    foreground=colors['grey'],
                    background=colors['focus'],
                ),

                widget.Memory(format='﬙{MemUsed: .0f}{mm}',
                              font="SF Pro Display Bold",
                              fontsize=12,
                              padding=10,
                              background=colors['grey'],
                              ),

                widget.TextBox(
                    text="",
                    font="Font Awesome 6 Free",
                    fontsize=18,
                    padding=0,
                    background=colors['grey'],
                ),

                widget.PulseVolume(font='SF Pro Display Bold',
                                   fontsize=12,
                                   padding=10,
                                   background=colors['grey'],
                                   ),


                widget.TextBox(
                    text="",
                    font="SF Pro Display Bold",
                    fontsize=30,
                    padding=0,
                    foreground=colors['dark'],
                    background=colors['grey'],
                ),

                widget.Clock(
                    format='  %I:%M %p',
                    background=colors['dark'],
                    font="SF Pro Display Bold",
                ),

                widget.Spacer(
                    length=18,
                    background=colors['dark'],
                ),
            ],
            30,
            margin=[8, 8, 8, 8]
        ),
    ),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=1,
)
extension_defaults = widget_defaults.copy()
