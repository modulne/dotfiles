function dpush --wraps='chezmoi cd && git add . && git commit -m "Update" && git push && exit'
    # Navigate to the chezmoi source directory
    cd (chezmoi source-path)
    chezmoi add ~/.config/fish ~/.config/nvim

    # Add all changes
    git add .

    # Check if a message was provided; otherwise use "Update"
    if test (count $argv) -gt 0
        git commit -m "$argv"
    else
        git commit -m "Update dotfiles"
    end

    # Push to GitHub
    git push

    # Return to the previous directory instead of exiting the terminal
    prevd

    echo "🚀 Dotfiles synced successfully!"
end
